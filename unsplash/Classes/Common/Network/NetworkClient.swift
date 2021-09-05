//
//  NetworkClient.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import Foundation
import UIKit.UIImage

enum NetworkError: Error {
    /// Resposne
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case notDefined(code: Int)
    /// Parsing
    case badUrl
    case badDecode
    /// Connection
    case offline
    /// Etc
    case unknown
}

class NetworkClient {
    private let accessKey = "Bu2ZhYMKtcf2ghmCHddOBb5cvMSDpq1YlBuGTbODLI8"
    private let session = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    private var _urlString: String = ""
    private var _page: UInt = 1
    
    func urlString(_ urlString: String) -> NetworkClient {
        _urlString = urlString
        return self
    }
    func page(_ page: UInt) -> NetworkClient {
        _page = page
        return self
    }
    func request<ResultData: Decodable>(completion: @escaping (Result<ResultData, NetworkError>) -> Void) {
        
        guard var urlComponents = URLComponents(string: _urlString) else { return completion(.failure(.badUrl)) }
        urlComponents.query = "client_id=\(accessKey)&page=\(_page)"
        guard let url = urlComponents.url else { return completion(.failure(.badUrl)) }
        
        print("[NetworkClient] url \(url)")

        task?.cancel()
        
        
        task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return completion(.failure(.unknown)) }
            
            defer {
                self.task = nil
            }
            
//            if let data = data, let text = String(data: data, encoding: .utf8) {
//                print("[NetworkClient] text \(text)")
//            }
            
            if let error = error {
                let nsError = error as NSError
                switch nsError.code {
                case -1009:
                    return completion(.failure(.offline))
                default:
                    return completion(.failure(.unknown))
                }
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
                    return completion(.failure(.notDefined(code: response.statusCode)))
                }
            } else {
                return completion(.failure(.unknown))
            }
        }
        task?.resume()
    }
    
    private func result<ResultData: Decodable>(_ data: Data) -> Result<ResultData, NetworkError> {
        do {
            let model = try JSONDecoder().decode(ResultData.self, from: data)
            return .success(model)
        } catch {
            return .failure(.badDecode)
        }
    }
}
