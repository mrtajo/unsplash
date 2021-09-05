//
//  HomeViewModel.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/23.
//

import Foundation
import UIKit.UIColor
import UIKit.UIImage

struct HomeViewModel {
    let networkClient = NetworkClient()
    
    // MARK: - Binds properties
    let photos: Publisher<[HomeViewModel.Photo]> = Publisher([HomeViewModel.Photo]())
    
    var page: UInt = 0
    var shouldFetch: Bool = true {
        didSet {
            print("[HomeViewModel] shouldFetch \(shouldFetch)")
        }
    }
    
    // MARK: - Commands
    mutating func fetchPhotos() {
        guard shouldFetch else { return }
        shouldFetch = false
        page += 1
        print("[HomeViewModel] page \(page)")
        
        let this = self
        networkClient
            .urlString("https://api.unsplash.com/photos")
            .page(page)
            .request { (result: Result<[HomeModel.Photo], NetworkError>) in
                switch result {
                case .success(let photos):
                    let viewModels = photos.map { HomeViewModel.Photo(model: $0) }
                    this.appendPhotos(viewModels)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func appendPhotos(_ viewModels: [HomeViewModel.Photo]) {
        var total: [HomeViewModel.Photo] = self.photos.value
        total.append(contentsOf: viewModels)
        self.photos.value = total
    }
    
}

extension HomeViewModel {
    struct Photo {
        let width: Int
        let height: Int
        let color: UIColor?
        let likedByUser: Bool
        let userName: String
        let imageUrlString: String
        let image: Publisher<UIImage?> = Publisher(nil)
        
        init(model: HomeModel.Photo) {
            width = model.width
            height = model.height
            color = UIColor(hexString: model.color)
            likedByUser = model.likedByUser
            userName = model.user.name
            imageUrlString = model.urls.regular
            self.requestImage()
        }
        
        func requestImage() {
            guard let url = URL(string: imageUrlString) else { return }
            let this = self
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                      let data = data, error == nil,
                      let image = UIImage(data: data) else { return }
                this.image.value = image
            }.resume()
        }
    }
}
