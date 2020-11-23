//
//  Protocols.swift
//  Chat
//
//  Created by Алексей Никитин on 17.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

protocol NetworkParser {
    associatedtype ParseModel
    typealias ParserResult = Result<ParseModel, ErrorWithMessage>
    
    func parse(data: Data) -> ParserResult
}

protocol RequestConfig {
    associatedtype ParserProtocol: NetworkParser
    associatedtype AllowedRequest
        
    var parser: ParserProtocol { get }    
    func createRequestTask(for request: AllowedRequest, _ completion: @escaping (ParserProtocol.ParserResult) -> Void) -> URLSessionDataTask
}
