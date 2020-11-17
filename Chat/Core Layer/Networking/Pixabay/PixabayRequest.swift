//
//  PixabayRequest.swift
//  Chat
//
//  Created by Алексей Никитин on 17.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class PixabayRequestConfig: RequestConfig {
    typealias ParserProtocol = PixabayParser
    typealias AllowedRequest = AllowedRequests
    
    enum AllowedRequests: String {
        case images = "/"
        
        var path: String { "/api\(self.rawValue)" }
    }
    private let apiKey: String
    private(set) var parser = PixabayParser()
    private(set) lazy var components: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "pixabay.com"
        components.path = ""
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "image_type", value: "photo"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        return components
    }()
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func createRequestTask(for request: AllowedRequests, _ completion: @escaping (ParserProtocol.ParserResult) -> Void) -> URLSessionDataTask {
        components.path = request.path
        guard let url = components.url else {
            fatalError("Invalid UrlComponents")
        }
        return URLSession.shared.dataTask(with: url) {data, response, error in
            if let message = error?.localizedDescription {
                completion(.failure(ErrorWithMessage(message: message)))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode),
                  let data = data else {
                completion(.failure(ErrorWithMessage(message: "Response error")))
                return
            }
            
            completion(self.parser.parse(data: data))
        }
    }
}
