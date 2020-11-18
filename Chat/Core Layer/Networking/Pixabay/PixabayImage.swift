//
//  PixabayRequest.swift
//  Chat
//
//  Created by Алексей Никитин on 17.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

struct PixabayImage {
    private init() { }
    
    class Parser: NetworkParser {
        func parse(data: Data) -> Result<UIImage, ErrorWithMessage> {
            guard let image = UIImage(data: data) else {
                return .failure(ErrorWithMessage(message: "Invalid json"))
            }
            return .success(image)
        }
    }
    
    class PixabayRequestConfig: RequestConfig {
        typealias ParserProtocol = Parser
        typealias AllowedRequest = URL
        
        private(set) var parser = Parser()
        
        func createRequestTask(for request: URL, _ completion: @escaping (ParserProtocol.ParserResult) -> Void) -> URLSessionDataTask {
            return URLSession.shared.dataTask(with: request) {data, response, error in
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
