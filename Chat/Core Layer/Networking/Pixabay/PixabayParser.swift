//
//  PixabayParser.swift
//  Chat
//
//  Created by Алексей Никитин on 17.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class PixabayParser: NetworkParser {
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
