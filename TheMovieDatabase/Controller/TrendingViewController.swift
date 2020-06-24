//
//  TrendingViewController.swift
//  TheMovieDatabase
//
//  Created by Ihor Vozhdai on 18.06.2020.
//  Copyright © 2020 Ihor Vozhdai. All rights reserved.
//

import UIKit

class TrendingViewController: UITableViewController {

    // MARK: - Variables
    let searchController = UISearchController(searchResultsController: nil)
    let networkDataFetcher = NetworkDataFetcher()
    var trendingMovies: TrendingMovies?
    var numberPageOfTrendingResults: Int = 1
    var numberPageOfSearchResults: Int = 1
    var searchText: String = ""
    private var timer: Timer?

    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        fetchTrendingMovies()
    }

    // sutup large search bar
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.obscuresBackgroundDuringPresentation = false
    }

    // get fetched trending movies
    private func fetchTrendingMovies() {
        networkDataFetcher.fetchTrendingMovies(pageNumber: numberPageOfTrendingResults) { trendingMovies in
            self.trendingMovies = trendingMovies
            self.tableView.reloadData()
        }
    }

    // Pagination: Fetch new page of movies for trending movies
    func fetchNextPageOfTrendingMovies() {
        networkDataFetcher.fetchTrendingMovies(pageNumber: numberPageOfTrendingResults) { fetchedNewPage in
            guard let newPage = fetchedNewPage else { return }
            for item in newPage.results {
                self.trendingMovies?.results.append(item)
            }
        }
    }

    // Pagination: Fetch new page of movies for search results
    func fetchNextPageOfSearchResults() {
        networkDataFetcher.fetchResultOfSearch(searchText: searchText,
                                               pageNumber: numberPageOfSearchResults) { searchResults in
                                                guard let newPageOfResults = searchResults else { return }
                                                for item in newPageOfResults.results {
                                                    self.trendingMovies?.results.append(item)
                                                }
        }
    }

    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingMovies?.results.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingCell", for: indexPath) as! TrendingCell
        let movie = trendingMovies?.results[indexPath.row]
        cell.titleLabel.text = movie?.title
        cell.descriptionLabel.text = movie?.overview
        if movie?.poster_path != nil {
            networkDataFetcher.downloadPosterImage(posterPath: (movie?.poster_path)!) { image in
                cell.poster.image = image
            }
        } else {
            cell.poster.image = UIImage(named: "404")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = storyboard?.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController
        guard let movie = trendingMovies?.results[indexPath.row] else { return }
        detailsVC.idOfSelectedMovie = movie.id
        detailsVC.titleOfSelectedMovie = movie.title
        detailsVC.posterPathOfSelectedMovie = movie.poster_path
        detailsVC.descriptionOfSelectedMovie = movie.overview
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    // MARK: - Pagination
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            if searchText == "" {
                fetchNextPageOfTrendingMovies()
                numberPageOfTrendingResults += 1
                tableView.reloadData()
            } else {
                fetchNextPageOfSearchResults()
                numberPageOfSearchResults += 1
                tableView.reloadData()
            }
        }
    }
}

// work with search request
extension TrendingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            if searchText != "" {
                self.networkDataFetcher.fetchResultOfSearch(searchText: searchText, pageNumber: self.numberPageOfSearchResults) { trendingMovies in
                    guard let trendingMovies = trendingMovies else { return }
                    self.trendingMovies = trendingMovies
                    self.tableView.reloadData()
                    self.searchText = searchText
                }
            } else {
                self.numberPageOfTrendingResults = 1
                self.trendingMovies?.results.removeAll()
                self.fetchTrendingMovies()
            }
        })
    }
}


