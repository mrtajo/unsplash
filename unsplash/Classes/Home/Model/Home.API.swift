//
//  Home.API.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/05.
//

import Foundation

extension Home.API {
    static func requestPhotos(completion: @escaping (Result<[Model.Photo], NetworkError>) -> Void) {
        networkClient.request(urlString: "https://api.unsplash.com/photos", completion: completion)
    }
}
