//
//  HomeViewModel.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/23.
//

import Foundation

struct HomeViewModel {
    let networkClient = NetworkClient()
    
    // MARK: - Binds properties
    let photos: Publisher<[HomeModel.Photo]> = Publisher([HomeModel.Photo]())
    
    // MARK: - Commands
    func fetchPhotos() {
        networkClient
            .urlString("https://api.unsplash.com/photos")
            .request { (result: Result<[HomeModel.Photo], NetworkError>) in
                switch result {
                case .success(let photos):
                    var total: [HomeModel.Photo] = self.photos.value
                    total.append(contentsOf: photos)
                    self.photos.value = total
                case .failure(let error):
                    print(error)
                }
            }
    }
}
