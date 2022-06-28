//
//  PhotoSelectionView.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation
import UIKit

class PhotoSelectionView: UIView {
    
    var activityIndicator: UIActivityIndicatorView?

    var photoCollectionView: UICollectionView?

    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Const.collectionViewSpacing
        layout.minimumLineSpacing = Const.collectionViewSpacing
        layout.sectionInset = UIEdgeInsets(top: Const.collectionViewSpacing,
                                           left: Const.collectionViewSpacing,
                                           bottom: Const.collectionViewSpacing,
                                           right: Const.collectionViewSpacing)
        return layout
    }()

    func configureView() {
        createCollection()
        configureActivityIndicator()
        configurePhotoCollection()
    }

    func getSizeForItemAt() -> CGSize {
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = flowLayout.minimumInteritemSpacing
        let availableWidth = bounds.width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemDimension, height: itemDimension)
    }
    
    func setCurrentTheme(_ themeManager: ThemeManagerProtocol) {
        self.backgroundColor = themeManager.themeSettings?.backgroundColor
        photoCollectionView?.backgroundColor = themeManager.themeSettings?.backgroundColor
    }
    
    private func createCollection() {
        photoCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
    }
    
    private func configurePhotoCollection() {
        if let photoCollectionView = photoCollectionView {
            self.addSubview(photoCollectionView)
            photoCollectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
            photoCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            configureTableViewAppearance()
        }
    }
    
    private func configureTableViewAppearance() {
        if let photoCollectionView = photoCollectionView {
            
            photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                photoCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                photoCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
                photoCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                photoCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }
    
    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator?.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.style = .large
        activityIndicator?.transform = CGAffineTransform(scaleX: 3, y: 3)
        if let activityIndicator = activityIndicator {
            photoCollectionView?.addSubview(activityIndicator)
        }
    }

    private enum Const {
        static let collectionViewSpacing: CGFloat = 5
    }
}
