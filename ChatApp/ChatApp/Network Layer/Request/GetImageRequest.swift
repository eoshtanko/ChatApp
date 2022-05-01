//
//  GetImageRequest.swift
//  ChatApp
//
//  Created by Екатерина on 30.04.2022.
//

import Foundation

struct GetImageRequest: IRequest {
    
    let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        let request = URLRequest(url: url)
        return request
    }
}
