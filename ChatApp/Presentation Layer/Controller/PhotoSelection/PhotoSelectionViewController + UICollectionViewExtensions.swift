//
//  PhotoSelectionViewController + UICollectionViewExtensions.swift
//  ChatApp
//
//  Created by Екатерина on 30.04.2022.
//

import UIKit

extension PhotoSelectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photoSelectionView = photoSelectionView else {
            return CGSize(width: 0, height: 0)
        }
        return photoSelectionView.getSizeForItemAt()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        choosePhotoAction?(photoesURL[indexPath.row])
        dismiss(animated: true)
    }
}

extension PhotoSelectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoesURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        cell.downloadImageAction = downloadImage
        cell.configure(with: photoesURL[indexPath.row])
        
        if indexPath.row == photoesURL.count - 1 {
            currentAPICallPage += 1
            downloadImages(page: currentAPICallPage, completitionSuccess: completitionSuccessForRepeatedRequest, competitionFailer: nil)
        }
        
        return cell
    }
    
    private func completitionSuccessForRepeatedRequest(_ moreImageModels: [UnsplashPhoto]) {
        for model in moreImageModels {
            if let url = model.urls[ImageSize.small.rawValue] {
                photoesURL.append(url)
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.photoSelectionView?.photoCollectionView?.reloadData()
        }
    }
}
