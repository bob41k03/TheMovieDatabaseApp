//
//  DetailsViewController.swift
//  TheMovieDatabase
//
//  Created by Ihor Vozhdai on 21.06.2020.
//  Copyright © 2020 Ihor Vozhdai. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var posterImg: UIImageView!
    @IBOutlet weak var movieDescription: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var directorsLabel: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    
    // MARK: - Variables
    let networkDataFetcher = NetworkDataFetcher()
    var movieDetails: MovieDetails?
    var idOfSelectedMovie: Int?
    var titleOfSelectedMovie: String?
    var posterPathOfSelectedMovie: String?
    var descriptionOfSelectedMovie: String?

    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = false
        fetchMoviePoster()
        fetchDetailsData()
        movieTitle.text = titleOfSelectedMovie
        movieDescription.text = descriptionOfSelectedMovie
    }

    // get poster for selected movie
    private func fetchMoviePoster() {
        if posterPathOfSelectedMovie != nil {
            networkDataFetcher.downloadPosterImage(posterPath: posterPathOfSelectedMovie!) { image in
                self.posterImg.image = image
            }
        } else {
            posterImg.image = UIImage(named: "404")
        }
    }

    // get and show details of selected movie
    private func fetchDetailsData() {
        networkDataFetcher.fetchDetailsInfoOfSelectedMovie(movieId: idOfSelectedMovie ?? 0) { movieDetails in
            self.movieDetails = movieDetails
            self.collection.reloadData()

            guard let dateOfRelease = self.movieDetails?.release_date else { return }
            self.releaseDate.text = dateOfRelease

            let genres = self.movieDetails?.genres.map({$0.name!}).joined(separator: ", ")
            guard let unwrapedGenres = genres else { return }
            self.genresLabel.text = "Genres: \(unwrapedGenres)"

            let directors = self.movieDetails?.credits.crew.filter({ $0.job!.contains("Producer") }).map({$0.name!}).joined(separator: ", ")
            guard let unwrapedDirectors = directors else { return }
            self.directorsLabel.text = "Directors: \(unwrapedDirectors)"
        }
    }
}

// MARK: - CollectionView DataSourse
extension DetailsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numberOfItem = movieDetails?.credits.cast.count else { return 0}
        return numberOfItem
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let actors = movieDetails?.credits.cast[indexPath.item]

        cell.actorNameLabel.text = actors?.name
        cell.characterLabel.text = actors?.character

        if actors?.profile_path != nil {
            networkDataFetcher.downloadPosterImage(posterPath: (actors?.profile_path)!) { image in
                cell.actorPhoto.image = image
            }
        } else {
            cell.actorPhoto.image = UIImage(named: "404")
        }
        return cell
    }
}
