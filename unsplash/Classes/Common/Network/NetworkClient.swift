//
//  NetworkClient.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import Foundation

enum QueryError: Error {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case unsplash
    case network(error: Error)
    case parse
    case unknown
}

class NetworkClient {
    typealias QueryResult = Result<Any, QueryError>
    typealias JSONDictionary = [String: Any]
    
    let session = URLSession(configuration: .default)
    
    var task: URLSessionDataTask?
    
    func query(url: URL, completion: @escaping (QueryResult) -> Void) {
        
        task?.cancel()
        
        task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return completion(.failure(.unknown)) }
            
            defer {
                self.task = nil
            }
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                print(text)
            }
            
            if let error = error {
                return completion(.failure(.network(error: error)))
            } else if let data = data, let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    return completion(self.result(data))
                case 400:
                    return completion(.failure(.badRequest))
                case 401:
                    return completion(.failure(.unauthorized))
                case 403:
                    return completion(.failure(.forbidden))
                case 404:
                    return completion(.failure(.notFound))
                default:
                    return completion(.failure(.unsplash))
                }
            } else {
                return completion(.failure(.unknown))
            }
        }
        task?.resume()
    }
    
    func result(_ data: Data) -> QueryResult {
        var response: JSONDictionary?
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            print(parseError)
            return .failure(.parse)
        }
        
        guard let response = response else { return .failure(.unknown)}
        
        print(response)
        
        
        return .success(data)
    }
}
