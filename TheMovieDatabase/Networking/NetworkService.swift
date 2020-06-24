//
//  NetworkService.swift
//  TheMovieDatabase
//
//  Created by Ihor Vozhdai on 19.06.2020.
//  Copyright © 2020 Ihor Vozhdai. All rights reserved.
//

import Foundation

class NetworkService {
    // Create session
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                completion(.success(data))
            }
        }.resume()
    }
}
