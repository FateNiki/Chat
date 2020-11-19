//
//  OnlineImageLibrary.swift
//  Chat
//
//  Created by Алексей Никитин on 18.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

struct Image {
    var previewUrl: URL
    var originUrl: URL
}

enum ImageResult {
    case success(UIImage)
    case loading(URLSessionDataTask)
}

extension PixabayListImages.Parser.Response.Hit {
    func toImage() -> Image? {
        guard let previewUrl = URL(string: self.previewURL),
              let originUrl = URL(string: self.largeImageURL) else {
            return nil
        }
        return Image(previewUrl: previewUrl, originUrl: originUrl)
    }
}

protocol OnlineImageLibrary {
    func getImagesList(_ completion: @escaping (ErrorWithMessage?) -> Void)
    func getImage(for index: Int, _ completion: @escaping (UIImage, Int) -> Void) -> ImageResult
    var count: Int { get }
}

class PixabayImageLibrary: OnlineImageLibrary {
    private let listRequest: PixabayListImages.PixabayRequestConfig
    private let imageRequest: PixabayImage.PixabayRequestConfig
    
    private var images: [Image] = [] {
        didSet {
            imageResults.forEach { result in
                switch result {
                case .loading(let task):
                    task.cancel()
                default:
                    break
                }
            }
            imageResults = .init(repeating: nil, count: images.count)
        }
    }
    private var imageResults: [ImageResult?] = []
    
    var count: Int { images.count }

    init(listRequest: PixabayListImages.PixabayRequestConfig, imageRequest: PixabayImage.PixabayRequestConfig) {
        self.listRequest = listRequest
        self.imageRequest = imageRequest
    }
    
    func getImagesList(_ completion: @escaping (ErrorWithMessage?) -> Void) {
        let task = listRequest.createRequestTask(for: .images) { result in
            switch result {
            case .failure(let error):
                completion(error)
            case.success(let response):
                self.images = response.hits.compactMap { $0.toImage() }
                completion(nil)
            }
        }
        task.resume()
    }
    
    func getImage(for index: Int, _ completion: @escaping (UIImage, Int) -> Void) -> ImageResult {
        guard (0..<images.count).contains(index) else {
            fatalError("INDEX ERROR")
        }
        
        if let imageResult = imageResults[index] {
            return imageResult
        }
        
        let task = imageRequest.createRequestTask(for: images[index].previewUrl) {[weak self] result in
            switch result {
            case .success(let image):
                self?.imageResults[index] = .success(image)
                completion(image, index)
            case .failure:
                break
            }
        }
        imageResults[index] = .loading(task)
        return .loading(task)
    }
}
