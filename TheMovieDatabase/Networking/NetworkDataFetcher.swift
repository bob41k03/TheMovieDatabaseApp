//
//  DataFetcher.swift
//  TheMovieDatabase
//
//  Created by Ihor Vozhdai on 19.06.2020.
//  Copyright © 2020 Ihor Vozhdai. All rights reserved.
//

import Foundation
import UIKit

class NetworkDataFetcher {

    private let networkService = NetworkService()
    private let urlScheme = "https"
    private let urlHost = "api.themoviedb.org"

    // fetch movies for main screen (trending movies)
    func fetchTrendingMovies(pageNumber: Int, completion: @escaping (TrendingMovies?) -> Void) {

        var components = URLComponents()
        components.scheme = urlScheme
        components.host = urlHost
        components.path = "/3/trending/movie/week"
        components.queryItems = [URLQueryItem(name: "api_key", value: "2d41304b77814da190f8a45c885b901b"),
                                 URLQueryItem(name: "page", value: "\(pageNumber)")]
        guard let url = components.url else { return }
        networkService.request(url: url) { (result) in
            switch result {
            case .success(let data):
                do {
                    let movie = try JSONDecoder().decode(TrendingMovies.self, from: data)
                    completion(movie)
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                    completion(nil)
                }
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    // fetch movies by search request
    func fetchResultOfSearch(searchText: String, pageNumber: Int, completion: @escaping (TrendingMovies?) -> Void) {

        var components = URLComponents()
        components.scheme = urlScheme
        components.host = urlHost
        components.path = "/3/search/movie"
        components.queryItems = [URLQueryItem(name: "api_key", value: "2d41304b77814da190f8a45c885b901b"),
                                 URLQueryItem(name: "query", value: searchText),
                                 URLQueryItem(name: "page", value: "\(pageNumber)")]
        guard let url = components.url else { return }
        networkService.request(url: url) { (result) in
            switch result {
            case .success(let data):
                do {
                    let movie = try JSONDecoder().decode(TrendingMovies.self, from: data)
                    completion(movie)
                } catch let jsonError {
                    print("Failed to decode JSON (fetchResultOfSearch)", jsonError)
                    completion(nil)
                }
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    // fetch detail info about selected movie
    func fetchDetailsInfoOfSelectedMovie(movieId: Int, completion: @escaping (MovieDetails?) -> Void) {

        var components = URLComponents()
        components.scheme = urlScheme
        components.host = urlHost
        components.path = "/3/movie/\(movieId)"
        components.queryItems = [URLQueryItem(name: "api_key", value: "2d41304b77814da190f8a45c885b901b"),
                                 URLQueryItem(name: "append_to_response", value: "credits")]
        guard let url = components.url else { return }
        networkService.request(url: url) { (result) in
            switch result {
            case .success(let data):
                do {
                    let movie = try JSONDecoder().decode(MovieDetails.self, from: data)
                    completion(movie)
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                    completion(nil)
                }
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    // get image by url
    func downloadPosterImage(posterPath: String, completion: @escaping (_ image: UIImage)->()) {
      
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = "image.tmdb.org"
        components.path = "/t/p/w500"+posterPath
        guard let url = components.url else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        } .resume()
    }
}
