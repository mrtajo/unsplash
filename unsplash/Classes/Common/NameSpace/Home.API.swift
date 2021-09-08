//
//  Payment.API.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/08.
//

import Foundation

extension Home.API {
    static func unsplashURL() -> URL? {
        return URL(string: "https://(Host.prefix(Phase.current))apollo.kakaopay.com/v1/cashreceipt/management/info")
    }
}
