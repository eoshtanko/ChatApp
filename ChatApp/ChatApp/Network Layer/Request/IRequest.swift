//
//  IRequest.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

protocol IRequest {
    var urlRequest: URLRequest? { get }
}

extension IRequest {
    
    func paramsToString(params: [String: String]) -> String {
        let parameterArray = params.map { key, value in
            return "\(key)=\(value)"
        }
        
        return "&" + parameterArray.joined(separator: "&")
    }
}
