//
//  ImageParser.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import UIKit

struct HitsModel: Codable {
    let total: Int
    let totalHits: Int
    let hits: [ImageData]
}

struct ImageData: Identifiable, Codable {
    let id: Int
    let largeImageURL: String
}

class ImageParser: IParser {
    
    typealias Model = [ImageData]
    
    func parse(data: Data) -> [ImageData]? {
        guard let imagesModel = try? JSONDecoder().decode(HitsModel.self, from: data) else {
            return nil
        }
        return imagesModel.hits
    }
}
