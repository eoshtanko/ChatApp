//
//  PhotoCell.swift
//  ChatApp
//
//  Created by Екатерина on 29.04.2022.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let identifier = String(describing: PhotoCell.self)
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImageView.frame = bounds
    }
    
    func configure(with image: UIImage?) {
        if let image = image {
            photoImageView.image = image
            setNeedsLayout()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = UIImage(named: "defaultImage")
    }
}
