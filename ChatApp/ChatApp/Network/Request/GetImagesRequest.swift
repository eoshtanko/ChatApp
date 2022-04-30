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
        // todo переделать:
        guard let url = URL(string: URLProvider.apiStringURL + "&q=blue+nature&image_type=photo&colors=blue&page=\(pageNumber)&per_page=200") else {
            return nil
        }
        let request = URLRequest(url: url)
        return request
    }
}
