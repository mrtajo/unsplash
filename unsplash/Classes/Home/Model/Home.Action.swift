//
//  Home.Action.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/05.
//

import Foundation

extension Home.Action {
    static func fetchPhotos() {
        API.requestPhotos { result in
            switch result {
            case .success(let photos):
                self.photos.append(contentsOf: photos)
                print(photos)
            case .failure(let error):
                print(error)
            }
        }
    }
}
