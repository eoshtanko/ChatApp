//
//  PhotoSelectionViewController.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation
import UIKit

class PhotoSelectionViewController: UIViewController {
    
    private var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
            setCurrentTheme()
        }
    }
    
    private var activityIndicator: UIActivityIndicatorView?
    
    private let requestSender = RequestSender()
    
    var photoCollectionView: UICollectionView?
    var photoesURL: [String] = []
    
    private var currentAPICallPage = 1
    
    var choosePhotoAction: ((String) -> Void)?
    
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
    
    init(choosePhotoAction: ((String) -> Void)?) {
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCurrentTheme()
    }
    
    func setCurrentTheme(_ theme: Theme?) {
        if let theme = theme {
            currentTheme = theme
        }
    }
    
    private func configurePhotoCollection() {
        if let photoCollectionView = photoCollectionView {
            view.addSubview(photoCollectionView)
            photoCollectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
            photoCollectionView.delegate = self
            photoCollectionView.dataSource = self
            photoCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        }
    }
    
    private func downloadImage(from url: String, competition: ((UIImage) -> Void)?) {
        let requestConfig = RequestsFactory.ImageRequests.getImage(urlString: url)
        requestSender.send(config: requestConfig) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        competition?(image)
                    }
                }
            case .failure(let failure):
                print(failure)
            }
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
        for imageModel in imageModels {
            self.photoesURL.append(imageModel.largeImageURL)
        }
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.photoCollectionView?.reloadData()
        }
    }
    
    private func completitionFailerForInitialRequest(_ failure: Error) {
        DispatchQueue.main.async {
            print(failure)
            self.activityIndicator?.stopAnimating()
        }
    }
    
    func setCurrentTheme() {
        view.backgroundColor = themeManager.themeSettings?.backgroundColor
        photoCollectionView?.backgroundColor = themeManager.themeSettings?.backgroundColor
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
        choosePhotoAction?(photoesURL[indexPath.row])
        self.dismiss(animated: true)
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
            
            self.loadImages(page: currentAPICallPage, completitionSuccess: completitionSuccessForRepeatedRequest, competitionFailer: nil)
        }
        
        return cell
    }
    
    private func completitionSuccessForRepeatedRequest(_ moreImageModels: [ImageData]) {
        for model in moreImageModels {
            photoesURL.append(model.largeImageURL)
        }
        DispatchQueue.main.async {
            self.photoCollectionView?.reloadData()
        }
    }
}
