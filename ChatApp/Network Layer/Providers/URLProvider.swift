//
//  URLProvider.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

public struct URLProvider {
    
    public static let imagesHost = Bundle.main.object(forInfoDictionaryKey: "imagesHost") as? String
    public static let imagesApiStringURL = Bundle.main.object(forInfoDictionaryKey: "imagesApiUrl") as? String
}
