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
    private var currentAPICallPage = 1
    
    var choosePhotoAction: ((UIImage) -> Void)?
    
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
    
    init(choosePhotoAction: ((UIImage) -> Void)?) {
        self.choosePhotoAction = choosePhotoAction
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
        configurePhotoCollection()
        configureActivityIndicator()
        activityIndicator?.startAnimating()
        loadImages(page: 1, completitionSuccess: completitionSuccessForInitialRequest(_:), competitionFailer: completitionFailerForInitialRequest(_:))
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
    
    private func loadImages(page: Int, completitionSuccess: (([ImageData]) -> Void)?, competitionFailer: ((Error) -> Void)?) {
        let requestConfig = RequestsFactory.ImageRequests.getImages(pageNumber: page)
        requestSender.send(config: requestConfig) { (result: Result<[ImageData], Error>) in
            switch result {
            case .success(let imageModels):
                completitionSuccess?(imageModels)
            case .failure(let failure):
                competitionFailer?(failure)
            }
        }
    }
    
    private func completitionSuccessForInitialRequest(_ imageModels: [ImageData]) {
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
    }
    
    private func completitionFailerForInitialRequest(_ failure: Error) {
        DispatchQueue.main.async {
            print(failure)
            self.activityIndicator?.stopAnimating()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photo = photoes[indexPath.row] {
            choosePhotoAction?(photo)
            self.dismiss(animated: true)
        }
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
        
        if indexPath.row == photoes.count - 1 {
            currentAPICallPage += 1
            
            self.loadImages(page: currentAPICallPage, completitionSuccess: completitionSuccessForRepeatedRequest, competitionFailer: nil)
        }
        
        return cell
    }
    
    private func completitionSuccessForRepeatedRequest(_ moreImageModels: [ImageData]) {
        DispatchQueue.main.async {
            let newPhotoes = Array(repeating: UIImage(named: "defaultImage"), count: moreImageModels.count)
            self.photoes.append(contentsOf: newPhotoes)
            self.photoCollectionView?.reloadData()
        }
        for i in 0..<moreImageModels.count {
            if let url = URL(string: moreImageModels[i].largeImageURL) {
                self.downloadImage(from: url, index: 200 * (currentAPICallPage - 1) + i)
            }
        }
    }
}
