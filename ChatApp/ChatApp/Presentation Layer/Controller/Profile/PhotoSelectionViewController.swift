//
//  PhotoSelectionViewController.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation
import UIKit

class PhotoSelectionViewController: UIViewController {
    
    private var activityIndicator: UIActivityIndicatorView?
    
    private let requestSender = RequestSender()
    
    var photoCollectionView: UICollectionView?
    var photoes: [UIImage?] = []
    
    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Const.collectionViewSpacing
        layout.minimumLineSpacing = Const.collectionViewSpacing
        layout.sectionInset = UIEdgeInsets(top: Const.collectionViewSpacing,
                                           left: Const.collectionViewSpacing,
                                           bottom: Const.collectionViewSpacing,
                                           right: Const.collectionViewSpacing)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
        configurePhotoCollection()
        configureActivityIndicator()
        activityIndicator?.startAnimating()
        loadImages()
    }
    
    private func configurePhotoCollection() {
        if let photoCollectionView = photoCollectionView {
            view.addSubview(photoCollectionView)
            photoCollectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
            photoCollectionView.delegate = self
            photoCollectionView.dataSource = self
        }
    }
    
    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator?.center = photoCollectionView?.center ?? view.center
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.style = .large
        activityIndicator?.transform = CGAffineTransform(scaleX: 3, y: 3)
        if let activityIndicator = activityIndicator {
            photoCollectionView?.addSubview(activityIndicator)
        }
    }
    
    private func loadImages() {
        let requestConfig = RequestsFactory.ImageRequests.getImages()
        requestSender.send(config: requestConfig) { (result: Result<[ImageData], Error>) in
            switch result {
            case .success(let imageModels):
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.photoes = Array(repeating: UIImage(named: "defaultImage"), count: imageModels.count)
                    self.photoCollectionView?.reloadData()
                }
                for i in 0..<imageModels.count {
                    if let url = URL(string: imageModels[i].largeImageURL) {
                        self.downloadImage(from: url, index: i)
                    }
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    print(failure)
                    self.activityIndicator?.stopAnimating()
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, index: Int) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async { [weak self] in
                self?.photoes[index] = UIImage(data: data)
                self?.photoCollectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
    
    enum Const {
        static let collectionViewSpacing: CGFloat = 5
    }
}

extension PhotoSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = flowLayout.minimumInteritemSpacing
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemDimension, height: itemDimension)
    }
}

extension PhotoSelectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
             return UICollectionViewCell()
        }
        
        let photo = photoes[indexPath.row]
        cell.configure(with: photo)
        
        return cell
    }
}
