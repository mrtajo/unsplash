//
//  Payment.Model.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/08.
//

import Foundation

extension Home.Model {
    struct Component: Decodable {
        var color: String?
        var textColor: String?
        var link: String?
        var linkType: String?
        var imageUrl: String?
        var header: String?
        var body: String?
        var buttonName: String?
        
        enum CodingKeys: String, CodingKey {
            case color
            case textColor = "font_color"
            case link
            case linkType = "link_type"
            case imageUrl = "image_url"
            case header
            case body
            case buttonName = "button_name"
        }
    }
}
