//
//  GetImagesRequest.swift
//  ChatApp
//
//  Created by Екатерина on 29.04.2022.
//

import Foundation

struct GetImagesRequest: IRequest {
    
    let pageNumber: Int
    
    init(pageNumber: Int) {
        self.pageNumber = pageNumber
    }
    
    var urlRequest: URLRequest? {
        guard let stringUrl = URLProvider.imagesApiStringURL else { return nil }
        
        var urlComponents = URLComponents(string: stringUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "q", value: "nature"),
            URLQueryItem(name: "image_type", value: "photo"),
            URLQueryItem(name: "colors", value: "blue"),
            URLQueryItem(name: "page", value: "\(pageNumber)"),
            URLQueryItem(name: "per_page", value: "200")
        ]
        
        guard let url = urlComponents?.url else { return nil }
        
        let request = URLRequest(url: url)
        return request
    }
}
