//
//  Publisher.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/23.
//

import Foundation

class Publisher<T> {
    typealias Subscriber = (T) -> Void
    var subscriber: Subscriber?
    
    var value: T {
        didSet {
            subscriber?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(subscriber: Subscriber?) {
        self.subscriber = subscriber
        subscriber?(value)
    }
}
