//
//  PhotoSelectionView.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation
import UIKit

class PhotoSelectionView: UIView {
    
//    var activityIndicator: UIActivityIndicatorView?
//
//    var photoCollectionView: UICollectionView?
//
//    private let flowLayout: UICollectionViewFlowLayout = {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = Const.collectionViewSpacing
//        layout.minimumLineSpacing = Const.collectionViewSpacing
//        layout.sectionInset = UIEdgeInsets(top: Const.collectionViewSpacing,
//                                           left: Const.collectionViewSpacing,
//                                           bottom: Const.collectionViewSpacing,
//                                           right: Const.collectionViewSpacing)
//        return layout
//    }()
//
//    func configureView() {
//        configureCollection()
//        configurePhotoCollection()
//        configureActivityIndicator()
//    }
//
//    func getSizeForItemAt() -> CGSize {
//        let width = photoCollectionView?.bounds.width
//        let numberOfItemsPerRow: CGFloat = 3
//        let spacing: CGFloat = flowLayout.minimumInteritemSpacing
//        let availableWidth = width ?? 0 - spacing * (numberOfItemsPerRow + 1)
//        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
//        return CGSize(width: itemDimension, height: itemDimension)
//    }
//
//    private func configureCollection() {
//        photoCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
//    }
//
//    private func configurePhotoCollection() {
//        if let photoCollectionView = photoCollectionView {
//            self.addSubview(photoCollectionView)
//            photoCollectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
//        }
//    }
//
//    private func configureActivityIndicator() {
//        activityIndicator = UIActivityIndicatorView()
//        activityIndicator?.center = photoCollectionView?.center ?? center
//        activityIndicator?.hidesWhenStopped = true
//        activityIndicator?.style = .large
//        activityIndicator?.transform = CGAffineTransform(scaleX: 3, y: 3)
//        if let activityIndicator = activityIndicator {
//            photoCollectionView?.addSubview(activityIndicator)
//        }
//    }
//
//    enum Const {
//        static let collectionViewSpacing: CGFloat = 5
//    }
}
