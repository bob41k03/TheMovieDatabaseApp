//
//  TrendingMovieModel.swift
//  TheMovieDatabase
//
//  Created by Ihor Vozhdai on 19.06.2020.
//  Copyright © 2020 Ihor Vozhdai. All rights reserved.
//

import Foundation

struct TrendingMovies: Codable {
    var results: [TrendingMovie]
}

struct TrendingMovie: Codable {
    var id: Int?
    var poster_path: String?
    var title: String?
    var overview: String?
}
