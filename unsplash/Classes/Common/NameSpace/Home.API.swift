//
//  Payment.API.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/08.
//

import Foundation

extension Home.API {
    static func requestPhotos(completion: @escaping (Result<[Model.Photo], NetworkError>) -> Void) {
        networkClient
            .urlString("https://api.unsplash.com/photos")
            .request(completion: completion)
    }
}

