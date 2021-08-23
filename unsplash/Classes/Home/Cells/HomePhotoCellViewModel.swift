//
//  HomePhotoCellViewModel.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/23.
//

import Foundation
import UIKit.UIColor
import UIKit.UIImage

struct HomePhotoCellViewModel {
    private let networkClient = NetworkClient()
    
    let image: Publisher<UIImage?> = Publisher(nil)
    
    let id: String
    let width: Int
    let height: Int
    let color: UIColor?
    let likedByUser: Bool
    let description: String?
    let userName: String
    let imageUrlString: String
    
    init(model: HomeModel.Photo) {
        id = model.id
        width = model.width
        height = model.height
        color = UIColor(hexString: model.color)
        likedByUser = model.likedByUser
        description = model.description
        userName = model.user.name
        imageUrlString = model.urls.regular
    }
    
    func setup() {
        let this = self
        networkClient
            .urlString(imageUrlString)
            .requestImage { result in
                switch result {
                case .success(let image):
                    this.image.value = image
                case .failure(_):
                    this.image.value = nil
                }
            }
    }
}
