//
//  PixabayParser.swift
//  Chat
//
//  Created by Алексей Никитин on 17.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

struct PixabayListImages {
    private init() { }
    class Parser: NetworkParser {
        struct Response: Codable {
            struct Hit: Codable {
                let previewURL: String
                let largeImageURL: String
            }
            let total: Int
            let hits: [Hit]
        }
        
        func parse(data: Data) -> Result<Response, ErrorWithMessage> {
            guard let reponse = try? JSONDecoder().decode(Response.self, from: data) else {
                return .failure(ErrorWithMessage(message: "Invalid json"))
            }
            return .success(reponse)
        }
    }
    
    enum AllowedRequests: String {
        case images = "/"
        
        var path: String { "/api\(self.rawValue)" }
    }
    
    class PixabayRequestConfig: RequestConfig {
        typealias ParserProtocol = Parser
        typealias AllowedRequest = AllowedRequests
        
        private let apiKey: String
        private(set) var parser = PixabayListImages.Parser()
        private(set) lazy var components: URLComponents = {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "pixabay.com"
            components.path = ""
            components.queryItems = [
                URLQueryItem(name: "key", value: apiKey),
                URLQueryItem(name: "image_type", value: "photo"),
                URLQueryItem(name: "per_page", value: "100")
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
}
