//
//  UIImage + Extensions.swift
//  ChatApp
//
//  Created by Екатерина on 31.03.2022.
//

import Foundation
import UIKit

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
