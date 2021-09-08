//
//  Home.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/08.
//

import Foundation

struct Home {}

extension Home{
    struct Model {}
    struct API {
        typealias Model = Home.Model
    }
    struct Action {
        typealias Model = Home.Model
        typealias API = Home.API
    }
}

protocol HomeNamespace {
    typealias API = Home.API
    typealias Model = Home.Model
    typealias Action = Home.Action
}
