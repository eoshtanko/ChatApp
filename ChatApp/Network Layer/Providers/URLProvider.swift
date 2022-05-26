//
//  URLProvider.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

public struct URLProvider {
    
    public static let imagesApiNetProtocolAndHost = Bundle.main.object(
        forInfoDictionaryKey: "imagesApiNetProtocolAndHost") as? String
    public static let imagesApiStringURL = Bundle.main.object(forInfoDictionaryKey: "imagesApiUrl") as? String
}
