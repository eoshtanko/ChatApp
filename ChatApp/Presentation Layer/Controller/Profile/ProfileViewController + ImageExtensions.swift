//
//  ProfileViewController + ImageExtensions.swift
//  ChatApp
//
//  Created by Екатерина on 31.03.2022.
//

import Foundation
import UIKit

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            setPhoto(image)
        } else {
            showAlertWith(message: "No image found.")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func setPhoto(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.isProfileEditing {
                self.changeProfileEditingStatus(isEditing: true)
            }
            self.profileView?.setImage(image: image)
            self.imageDidChanged = true
            self.setEnableStatusToSaveButtons()
        }
    }
    
    private func setPhoto(_ urlString: String) {
        downloadImage(from: urlString, competition: setPhoto)
    }
    
    private func downloadImage(from url: String, competition: ((UIImage) -> Void)?) {
        let requestConfig = RequestsFactory.ImageRequests.getImage(urlString: url)
        requestSender.send(config: requestConfig) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        competition?(image)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.showAlertWith(message: "Unable to download photo from internet")
                }
                print(error.localizedDescription)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func pickImage() {
        let imagePickerController = configureImagePickerController()
        let actionSheet = configureActionSheet()
        configureActions(actionSheet, imagePickerController)
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func configureImagePickerController() -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        return imagePickerController
    }
    
    private func configureActionSheet() -> UIAlertController {
        let actionSheet = UIAlertController(title: "Image Source", message: "Select the source of your profile image", preferredStyle: .actionSheet)
        return actionSheet
    }
    
    private func configureActions(_ actionSheet: UIAlertController, _ imagePickerController: UIImagePickerController) {
        configureLibraryAction(actionSheet, imagePickerController)
        configureCameraAction(actionSheet, imagePickerController)
        configureUploadAction(actionSheet)
        configureCancelAction(actionSheet)
    }
    
    private func configureLibraryAction(_ actionSheet: UIAlertController, _ imagePickerController: UIImagePickerController) {
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self?.present(imagePickerController, animated: true)
            } else {
                self?.showAlertWith(message: "Unable to access the photo library.")
            }
        }))
    }
    
    private func configureUploadAction(_ actionSheet: UIAlertController) {
        actionSheet.addAction(UIAlertAction(title: "Upload", style: .default, handler: { [weak self] _ in
            let photoSelectionViewController = PhotoSelectionViewController(choosePhotoAction: self?.setPhoto)
            photoSelectionViewController.setCurrentTheme(self?.currentTheme)
            self?.present(photoSelectionViewController, animated: true)
        }))
    }
    
    private func configureCameraAction(_ actionSheet: UIAlertController, _ imagePickerController: UIImagePickerController) {
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            actionSheet.dismiss(animated: true) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePickerController.sourceType = .camera
                    self?.present(imagePickerController, animated: true)
                } else {
                    self?.showAlertWith(message: "Unable to access the camera.")
                }
            }
        }))
    }
    
    private func configureCancelAction(_ actionSheet: UIAlertController) {
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    private func showAlertWith(message: String) {
        let alertController = UIAlertController(title: "Error when uploading a photo", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
