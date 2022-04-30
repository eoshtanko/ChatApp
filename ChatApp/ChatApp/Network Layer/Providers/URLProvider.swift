//
//  URLProvider.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation

public struct URLProvider {
    public static let netProtocol = "https://"
    public static let host = "pixabay.com"
    public static let apiStringURL = netProtocol + host + "/api/?key=\(KeyProvider.apiKey)"
}
