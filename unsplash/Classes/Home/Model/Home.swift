//
//  Home.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/05.
//

import Foundation

struct Home {
    struct Model {}
    struct API {
        typealias Model = Home.Model
        static let networkClient = NetworkClient()
    }
    struct Action {
        typealias Model = Home.Model
        typealias API = Home.API
        static var photos = [Model.Photo]()
    }
}

protocol HomeNamespace {
    typealias Model = Home.Model
    typealias API = Home.API
    typealias Action = Home.Action
}
