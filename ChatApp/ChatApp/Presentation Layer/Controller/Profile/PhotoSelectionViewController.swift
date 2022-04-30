//
//  PhotoSelectionViewController.swift
//  ChatApp
//
//  Created by Екатерина on 28.04.2022.
//

import Foundation
import UIKit

class PhotoSelectionViewController: UIViewController {
    
    var photoSelectionView: PhotoSelectionView? {
        view as? PhotoSelectionView
    }
    
    private var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
            photoSelectionView?.setCurrentTheme(themeManager)
        }
    }
    
    private var currentAPICallPage = 1
    private let requestSender = RequestSender()
    
    var photoesURL: [String] = []
    
    var choosePhotoAction: ((String) -> Void)?
    
    init(choosePhotoAction: ((String) -> Void)?) {
        self.choosePhotoAction = choosePhotoAction
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = PhotoSelectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoSelectionView?.configureView()
        configurePhotoCollection()
        photoSelectionView?.activityIndicator?.startAnimating()
        downloadImages(page: 1, completitionSuccess: completitionSuccessForInitialRequest(_:), competitionFailer: completitionFailerForInitialRequest(_:))
    }
    
    func setCurrentTheme(_ theme: Theme?) {
        if let theme = theme {
            currentTheme = theme
        }
    }
    
    private func configurePhotoCollection() {
        photoSelectionView?.photoCollectionView?.delegate = self
        photoSelectionView?.photoCollectionView?.dataSource = self
    }
    
    private func downloadImages(page: Int, completitionSuccess: (([ImageData]) -> Void)?, competitionFailer: ((Error) -> Void)?) {
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
            self.photoSelectionView?.activityIndicator?.stopAnimating()
            self.photoSelectionView?.photoCollectionView?.reloadData()
        }
    }
    
    private func completitionFailerForInitialRequest(_ failure: Error) {
        DispatchQueue.main.async {
            print(failure)
            self.photoSelectionView?.activityIndicator?.stopAnimating()
            self.showFailureAlert()
        }
    }
    
    private func showFailureAlert() {
        let successAlert = UIAlertController(title: "Ошибка", message: "Проверьте подключение к интернету.", preferredStyle: UIAlertController.Style.alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in
            self.dismiss(animated: true)
        })
        present(successAlert, animated: true, completion: nil)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoSelectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photoSelectionView = photoSelectionView else {
            return CGSize(width: 0, height: 0)
        }
        return photoSelectionView.getSizeForItemAt()
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
            self.downloadImages(page: currentAPICallPage, completitionSuccess: completitionSuccessForRepeatedRequest, competitionFailer: nil)
        }
        
        return cell
    }
    
    private func completitionSuccessForRepeatedRequest(_ moreImageModels: [ImageData]) {
        for model in moreImageModels {
            photoesURL.append(model.largeImageURL)
        }
        DispatchQueue.main.async {
            self.photoSelectionView?.photoCollectionView?.reloadData()
//            self.photoSelectionView?.photoCollectionView?.reloadItems(at:
//            self.photoSelectionView?.photoCollectionView?.indexPathsForVisibleItems ?? [])
        }
    }
}
