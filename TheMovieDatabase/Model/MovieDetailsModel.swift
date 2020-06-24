//
//  MovieDetailsModel.swift
//  TheMovieDatabase
//
//  Created by Ihor Vozhdai on 21.06.2020.
//  Copyright © 2020 Ihor Vozhdai. All rights reserved.
//

import Foundation

struct MovieDetails: Codable {
    var release_date: String
    var genres: [Genre]
    var credits: Credits
}

struct Credits: Codable {
    var cast: [Cast]
    var crew: [Crew]
}

struct Cast: Codable {
    var character: String?
    var name: String?
    var profile_path: String?
}

struct Crew: Codable {
    var job: String?
    var name: String?
}

struct Genre: Codable {
    var name: String?
}
