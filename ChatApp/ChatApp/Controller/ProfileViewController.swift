//
//  ViewController.swift
//  ChatApp
//
//  Created by Екатерина on 22.02.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    internal weak var conversationsListViewController: ConversationsListViewController?
    private var currentTheme: Theme = .classic
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLabel: UILabel!
    @IBOutlet weak var navigationBarButton: UIButton!
    
    @IBAction func editPhotoButtonPressed(_ sender: Any) {
        print("Выбери изображение профиля")
        pickImage()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private var imageDidChanged = false
    @IBAction func saveButtonPressed(_ sender: Any) {
        if imageDidChanged {
            CurrentUser.user.image = profileImageView.image
        }
        CurrentUser.user.name = nameLabel.text
        CurrentUser.user.info = infoLabel.text
        conversationsListViewController?.configureRightNavigationButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentTheme()
    }
    
    internal func setCurrentTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    private func configureSubviews() {
        configureNameLabel()
        configureInfoLabel()
        configureSaveButton()
        configureProfileImageView()
        configureEditPhotoButton()
    }
    
    private func configureNameLabel() {
        if (CurrentUser.user.name != nil) {
            nameLabel.text = CurrentUser.user.name
        }
        nameLabel.delegate = self
    }
    
    private func configureInfoLabel() {
        if (CurrentUser.user.info != nil) {
            infoLabel.text = CurrentUser.user.info
        }
        infoLabel.delegate = self
    }
    
    private func configureSaveButton() {
        saveButton.layer.cornerRadius = Const.buttonBorderRadius
        saveButton.clipsToBounds = true
    }
    
    private func configureProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        if(CurrentUser.user.image != nil) {
            profileImageView.image = CurrentUser.user.image
        }
    }
    
    private func configureEditPhotoButton() {
        editPhotoButton.setTitle("", for: .normal)
        editPhotoButton.layer.cornerRadius = editPhotoButton.frame.size.width / 2
        editPhotoButton.clipsToBounds = true
    }
    
    private func setCurrentTheme() {
        switch currentTheme {
        case .classic, .day:
            setDayOrClassicTheme()
        case .night:
            setNightTheme()
        }
    }
    
    private func setDayOrClassicTheme() {
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.light
        view.backgroundColor = .white
        nameLabel.textColor = .black
        infoLabel.textColor = .black
        infoLabel.backgroundColor = .white
        editPhotoButton.backgroundColor = UIColor(named: "CameraButtonColor")
        saveButton.setTitleColor(UIColor(named: "BlueTextColor"), for: .normal)
        saveButton.backgroundColor = .white
        navigationBar.backgroundColor = UIColor(named: "BackgroundNavigationBarColor")
        navigationBarLabel.textColor = .black
        navigationBarButton.setTitleColor(UIColor(named: "BlueTextColor"), for: .normal)
    }
    
    private func setNightTheme() {
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.dark
        view.backgroundColor = .black
        nameLabel.textColor = .white
        infoLabel.textColor = .white
        infoLabel.backgroundColor = .black
        editPhotoButton.backgroundColor = UIColor(named: "OutcomingMessageNightThemeColor")
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor(named: "OutcomingMessageNightThemeColor")
        navigationBar.backgroundColor = UIColor(named: "IncomingMessageNightThemeColor")
        navigationBarLabel.textColor = .white
        navigationBarButton.setTitleColor(.systemYellow, for: .normal)
    }
    
    private enum Const {
        static let buttonBorderRadius: CGFloat = 14
        static let maxNumOfCharsInName = 16
    }
}

// Все, что связано с UITextField.
extension ProfileViewController: UITextFieldDelegate {
    
    // Ввожу ограничение на максимальное количество символов в имени.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= Const.maxNumOfCharsInName
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension ProfileViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

// Все, что связано с установкой фото.
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = image
            imageDidChanged = true
        } else {
            self.showAlertWith(message: "No image found.")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func pickImage() {
        let imagePickerController = configureImagePickerController()
        let actionSheet = configureActionSheet()
        configureActions(actionSheet, imagePickerController)
        self.present(actionSheet, animated: true, completion: nil)
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
        configureCancelAction(actionSheet)
    }
    
    private func configureLibraryAction(_ actionSheet: UIAlertController, _ imagePickerController: UIImagePickerController) {
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true)
            } else {
                self.showAlertWith(message: "Unable to access the photo library.")
            }
        }))
    }
    
    private func configureCameraAction(_ actionSheet: UIAlertController, _ imagePickerController: UIImagePickerController) {
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            actionSheet.dismiss(animated: true) {
                if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true)
                } else {
                    self.showAlertWith(message: "Unable to access the camera.")
                }
            }
        }))
    }
    
    private func configureCancelAction(_ actionSheet: UIAlertController) {
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    private func showAlertWith(message: String){
        let alertController = UIAlertController(title: "Error when uploading a photo", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
