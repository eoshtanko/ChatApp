//
//  ImageParser.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import UIKit

struct UnsplashPhoto: Codable {
    public let urls: [String: String]
}

class ApiImagesParser: IParser {
    
    typealias Model = [UnsplashPhoto]
    
    func parse(data: Data) -> [UnsplashPhoto]? {
        guard let imagesModel = try? JSONDecoder().decode([UnsplashPhoto].self, from: data) else {
            return nil
        }
        return imagesModel
    }
}

public enum ImageSize: String {
    case raw
    case full
    case regular
    case small
    case thumb
}
