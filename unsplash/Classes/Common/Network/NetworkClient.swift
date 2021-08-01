//
//  NetworkClient.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import Foundation

enum QueryError: Error {
    case auth
    case network(error: Error)
    case unknown
}

class NetworkClient {
    typealias QueryResult = (Result<Any, QueryError>) -> Void
    
    let session = URLSession(configuration: .default)
    
    var task: URLSessionDataTask?
    
    func query(url: URL, completion: @escaping QueryResult) {
        
        task?.cancel()
        
        task = session.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.task = nil
            }
            
            if let error = error {
                return completion(.failure(.network(error: error)))
            } else if let data = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200 {
                return completion(.success(data))
            } else {
                return completion(.failure(.unknown))
            }
        }
        task?.resume()
    }
}
