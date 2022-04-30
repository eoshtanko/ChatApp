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
    
    var downloadImageAction: ((String, ((UIImage) -> Void)?) -> Void)?
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImageView.frame = bounds
    }
    
    func configure(with imageURL: String) {
        downloadImageAction?(imageURL, setImage)
        setNeedsLayout()
    }
    
    private func setImage(image: UIImage) {
        photoImageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = UIImage(named: "defaultImage")
    }
}
