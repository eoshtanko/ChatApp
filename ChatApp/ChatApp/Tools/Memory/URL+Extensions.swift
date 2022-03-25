//
//  URL+Extensions.swift
//  ChatApp
//
//  Created by Екатерина on 25.03.2022.
//

import Foundation

public extension URL {
    
    static func getPlistURL(plistFileName: String) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(plistFileName)
    }
}
