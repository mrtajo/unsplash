//
//  NetworkClient.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import Foundation

enum ResultError: Error {
    case network(error: ResponseError)
    case url
    case parse
    case unknown(error: Error?)
}

enum ResponseError: Error {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case unsplash
}

class NetworkClient {
    private let accessKey = "Bu2ZhYMKtcf2ghmCHddOBb5cvMSDpq1YlBuGTbODLI8"
    private let session = URLSession(configuration: .default)
    
    private var task: URLSessionDataTask?
    
    func request<ResultData: Decodable>(urlString: String, completion: @escaping (Result<ResultData, ResultError>) -> Void) {
        
        guard var urlComponents = URLComponents(string: urlString) else { return completion(.failure(.url)) }
        urlComponents.query = "client_id=\(accessKey)"
        guard let url = urlComponents.url else { return completion(.failure(.url)) }
        
        task?.cancel()
        
        task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return completion(.failure(.unknown(error: nil))) }
            
            defer {
                self.task = nil
            }
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                print(text)
            }
            
            if let error = error {
                return completion(.failure(.unknown(error: error)))
            } else if let data = data, let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    return completion(self.result(data))
                case 400:
                    return completion(.failure(.network(error: .badRequest)))
                case 401:
                    return completion(.failure(.network(error: .unauthorized)))
                case 403:
                    return completion(.failure(.network(error: .forbidden)))
                case 404:
                    return completion(.failure(.network(error: .notFound)))
                default:
                    return completion(.failure(.network(error: .unsplash)))
                }
            } else {
                return completion(.failure(.unknown(error: nil)))
            }
        }
        task?.resume()
    }
    
    func result<ResultData: Decodable>(_ data: Data) -> Result<ResultData, ResultError> {
        do {
            let model = try JSONDecoder().decode(ResultData.self, from: data)
            return .success(model)
        } catch let error {
            return .failure(.unknown(error: error))
        }
    }
}
