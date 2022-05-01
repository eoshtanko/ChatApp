//
//  ImageParser.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import UIKit

struct HitsModel: Codable {
    let hits: [ImageModel]
}

struct ImageModel: Identifiable, Codable {
    let id: Int
    let largeImageURL: String
}

class ApiImagesParser: IParser {
    
    typealias Model = [ImageModel]
    
    func parse(data: Data) -> [ImageModel]? {
        guard let imagesModel = try? JSONDecoder().decode(HitsModel.self, from: data) else {
            return nil
        }
        return imagesModel.hits
    }
}
