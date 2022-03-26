//
//  ImageManager.swift
//  ChatApp
//
//  Created by Екатерина on 24.03.2022.
//

import Foundation
import UIKit

class ImageManager {
    static let instace = ImageManager()
    
    func convertImageToString(image: UIImage) -> Data? {
        return image.pngData()
    }
    
    func convertUrlToImage(pngData: Data) -> UIImage? {
        return UIImage(data: pngData)
    }
}
