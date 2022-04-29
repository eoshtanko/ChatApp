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
    
    func configure(with imageURL: String) {
        if let url = URL(string: imageURL) {
            photoImageView.downloaded(from: url)
        }
        setNeedsLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = UIImage(named: "defaultImage")
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
