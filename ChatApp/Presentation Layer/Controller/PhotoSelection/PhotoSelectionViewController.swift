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
    
    var currentAPICallPage = 1
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
    
    func downloadImages(page: Int, completitionSuccess: (([UnsplashPhoto]) -> Void)?, competitionFailer: ((Error) -> Void)?) {
        let requestConfig = RequestsFactory.ImageRequests.getImages(pageNumber: page)
        requestSender.send(config: requestConfig) { (result: Result<[UnsplashPhoto], Error>) in
            switch result {
            case .success(let imageModels):
                completitionSuccess?(imageModels)
            case .failure(let failure):
                competitionFailer?(failure)
            }
        }
    }
    
    private func completitionSuccessForInitialRequest(_ imageModels: [UnsplashPhoto]) {
        for imageModel in imageModels {
            if let url = imageModel.urls[ImageSize.small.rawValue] {
                photoesURL.append(url)
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.photoSelectionView?.activityIndicator?.stopAnimating()
            self?.photoSelectionView?.photoCollectionView?.reloadData()
        }
    }
    
    private func completitionFailerForInitialRequest(_ failure: Error) {
        DispatchQueue.main.async { [weak self] in
            print(failure)
            self?.photoSelectionView?.activityIndicator?.stopAnimating()
            self?.showFailureAlert()
        }
    }
    
    private func showFailureAlert() {
        let successAlert = UIAlertController(title: "Ошибка", message: "Проверьте подключение к интернету.", preferredStyle: UIAlertController.Style.alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(successAlert, animated: true, completion: nil)
    }
    
    func downloadImage(from url: String, competition: ((UIImage) -> Void)?) {
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
