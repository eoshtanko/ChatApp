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
        let parametrs = ["page": "\(pageNumber)",
                         "per_page": "200"]
        
        guard let stringUrl = URLProvider.imagesApiStringURL,
              let url = URL(string: stringUrl + paramsToString(params: parametrs)) else {
                  return nil
              }
        
        let request = URLRequest(url: url)
        return request
    }
}
