//
//  ViewController.swift
//  ChatApp
//
//  Created by Екатерина on 22.02.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    weak var conversationsListViewController: ConversationsListViewController?
    
    private var currentTheme: Theme = .classic
    private var GCDSaver: GCDMemoryWriteToMemoryManager!
    private var operationSaver: OperationWriteToMemoryManager!
    private var activityIndicator: UIActivityIndicatorView!
    private var selectedSavingApproach: SavingApproach!
    
    private let operationQueue = OperationQueue()
    
    private let successAlert = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: UIAlertController.Style.alert)
    private let failureAlert = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные.", preferredStyle: UIAlertController.Style.alert)
    
    private var isProfileEditing: Bool = false
    private var imageDidChanged = false
    private var initialImage: UIImage?
    private var nameDidChanged = false
    private var initialName: String?
    private var infoDidChanged = false
    private var initialInfo: String?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveGCDButton: UIButton!
    @IBOutlet weak var saveOperationsButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLabel: UILabel!
    @IBOutlet weak var navigationBarButton: UIButton!
    @IBOutlet weak var buttonVerticalStackView: UIStackView!
    @IBOutlet weak var buttonHorizontalStackView: UIStackView!
    
    
    @IBAction func editPhotoButtonPressed(_ sender: Any) {
        print("Выбери изображение профиля")
        pickImage()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        changeProfileEditingStatus(isEditing: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        returnToInitialData()
        changeProfileEditingStatus(isEditing: false)
    }
    
    @IBAction func saveGCDButtonPressed(_ sender: Any) {
        saveViaGCD()
    }
    
    @IBAction func saveOperationsButtonPressed(_ sender: Any) {
        saveViaOperations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureOperationQueue()
        configureActivityIndicator()
        configureAlerts()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureStatusBar(.lightContent)
        setCurrentTheme()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configureStatusBar(.darkContent)
    }
    
    func setCurrentTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    private func hundleSaveToMemoryRequestResult(result: Result<User, Error>?) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let user):
                self?.hundleSuccessSaveToMemoryRequestResult(user)
            case .failure, .none:
                self?.hundleFailureSaveToMemoryRequestResult()
            }
            self?.finalizeSaving()
        }
    }
    
    private func hundleSuccessSaveToMemoryRequestResult(_ user: User) {
        CurrentUser.user = user
        conversationsListViewController?.configureRightNavigationButton()
        present(successAlert, animated: true, completion: nil)
    }
    
    private func hundleFailureSaveToMemoryRequestResult() {
        returnToInitialData()
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func finalizeSaving() {
        cancelButton.isEnabled = true
        editPhotoButton.isEnabled = true
        activityIndicator.stopAnimating()
    }
    
    private func changeProfileEditingStatus(isEditing: Bool) {
        changeHiddenPropertyOfButtons(isEditing)
        isProfileEditing = isEditing
        changeEnablePropertyOfFields(isEditing)
        disableSaveButtons()
        setInitialData()
        if !isEditing {
            resetChangeIndicators()
        }
        if isEditing {
            nameLabel.becomeFirstResponder()
        }
    }
    
    private func changeEnablePropertyOfFields(_ isEditing: Bool) {
        nameLabel.isUserInteractionEnabled = isEditing
        infoLabel.isUserInteractionEnabled = isEditing
    }
    
    private func changeHiddenPropertyOfButtons(_ isEditing: Bool) {
        editButton.isHidden = isEditing
        cancelButton.isHidden = !isEditing
        buttonHorizontalStackView.isHidden = !isEditing
    }
    
    private func disableSaveButtons() {
        saveGCDButton.isEnabled = false
        saveOperationsButton.isEnabled = false
    }
    
    private func setInitialData() {
        initialName = nameLabel.text
        initialInfo = infoLabel.text
        initialImage = profileImageView.image
    }
    
    private func resetChangeIndicators() {
        infoDidChanged = false
        nameDidChanged = false
        imageDidChanged = false
    }
    
    private func saveViaGCD() {
        selectedSavingApproach = .GCD
        prepareForSaving()
        let GCDSaver = GCDMemoryWriteToMemoryManager(objectToSave: getUserWithUpdatedData(), plistFileName: Const.plistFileName) {
            [weak self] result in
            self?.hundleSaveToMemoryRequestResult(result: result)
        }
        GCDSaver.loadUserToMemory()
    }
    
    private func saveViaOperations() {
        selectedSavingApproach = .operations
        prepareForSaving()
        let operationSaver = OperationWriteToMemoryManager(objectToSave: getUserWithUpdatedData(), plistFileName: Const.plistFileName) {
            [weak self] result in
            self?.hundleSaveToMemoryRequestResult(result: result)
        }
        operationQueue.addOperations([operationSaver], waitUntilFinished: true)
    }
    
    private func getUserWithUpdatedData() -> User {
        var image: Data?
        if let profileImageViewImage = profileImageView.image {
            image = ImageManager.instace.convertImageToString(image: profileImageViewImage)
        }
        return User(name: nameLabel.text, info: infoLabel.text, imageData: image)
    }
    
    private func prepareForSaving() {
        cancelButton.isEnabled = false
        editPhotoButton.isEnabled = false
        disableSaveButtons()
        changeEnablePropertyOfFields(false)
        activityIndicator.startAnimating()
    }
    
    private func returnToInitialData() {
        if nameDidChanged {
            returnToInitialName()
        }
        if infoDidChanged {
            returnToInitialInfo()
        }
        if imageDidChanged {
            returnToInitialImage()
        }
    }
    
    private func returnToInitialName() {
        nameLabel.text = initialName
    }
    
    private func returnToInitialInfo() {
        infoLabel.text = initialInfo
    }
    
    private func returnToInitialImage() {
        if initialImage == nil {
            setDefaultImage(to: profileImageView)
        } else {
            profileImageView.image = initialImage
        }
    }
    
    private func setDefaultImage(to imageView: UIImageView) {
        imageView.backgroundColor = UIColor(named: "BackgroundImageColor")
        imageView.tintColor = UIColor(named: "DefaultImageColor")
        imageView.image = UIImage(systemName: "person.fill")
    }
    
    private func configureOperationQueue() {
        operationQueue.qualityOfService = .utility
    }
    
    private func configureSubviews() {
        configureNameLabel()
        configureInfoLabel()
        configureButtons(editButton, cancelButton, saveGCDButton, saveOperationsButton)
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
        } else {
            infoLabel.text = Const.textViewPlaceholderText
            infoLabel.textColor = UIColor.lightGray
        }
        infoLabel.delegate = self
    }
    
    private func configureButtons(_ buttons: UIButton...) {
        for button in buttons{
            button.layer.cornerRadius = Const.buttonBorderRadius
            button.clipsToBounds = true
            button.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    private func configureProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        if let data = CurrentUser.user.imageData, let image = ImageManager.instace.convertUrlToImage(pngData: data) {
            profileImageView.image = image
        }
    }
    
    private func configureEditPhotoButton() {
        editPhotoButton.setTitle("", for: .normal)
        editPhotoButton.layer.cornerRadius = editPhotoButton.frame.size.width / 2
        editPhotoButton.clipsToBounds = true
    }
    
    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        view.addSubview(activityIndicator)
    }
    
    private func configureAlerts() {
        configureSuccessAlert()
        configureFailureAlert()
    }
    
    private func configureSuccessAlert() {
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in
            self.changeProfileEditingStatus(isEditing: false)
        })
    }
    
    private func configureFailureAlert() {
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in
            self.changeProfileEditingStatus(isEditing: false)
        })
        failureAlert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel) {_ in
            if self.selectedSavingApproach == .GCD {
                self.saveViaGCD()
            } else {
                self.saveViaOperations()
            }
        })
    }
    
    private func configureStatusBar(_ style: UIStatusBarStyle) {
        if currentTheme != .night {
            UIApplication.shared.statusBarStyle = style
        }
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
        view.backgroundColor = .white
        setDayOrClassicThemeToActivityIndicator()
        setDayOrClassicThemeToLabels()
        setDayOrClassicThemeToButtons()
        setDayOrClassicThemeToNavBar()
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.light
    }
    
    private func setDayOrClassicThemeToActivityIndicator() {
        activityIndicator.color = .darkGray
    }
    
    private func setDayOrClassicThemeToLabels() {
        nameLabel.textColor = .black
        nameLabel.attributedPlaceholder = NSAttributedString(string: Const.textFieldPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "DefaultImageColor") ?? .darkGray])
        infoLabel.textColor = .black
        infoLabel.backgroundColor = .white
    }
    
    private func setDayOrClassicThemeToButtons() {
        editPhotoButton.backgroundColor = UIColor(named: "CameraButtonColor")
        setDayOrClassicThemeToBottomButtons(editButton, cancelButton, saveGCDButton, saveOperationsButton)
    }
    
    private func setDayOrClassicThemeToBottomButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.setTitleColor(UIColor(named: "BlueTextColor"), for: .normal)
            button.backgroundColor = UIColor(named: "BackgroundButtonColor")
        }
    }
    
    private func setDayOrClassicThemeToNavBar() {
        navigationBar.backgroundColor = UIColor(named: "BackgroundNavigationBarColor")
        navigationBarLabel.textColor = .black
        navigationBarButton.setTitleColor(UIColor(named: "BlueTextColor"), for: .normal)
    }
    
    private func setNightTheme() {
        view.backgroundColor = .black
        setNightThemeToActivityIndicator()
        setNightThemeToLabels()
        setNightThemeToButtons()
        setNightThemeToNavBar()
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.dark
    }
    
    private func setNightThemeToActivityIndicator() {
        activityIndicator.color = .lightGray
    }
    
    private func setNightThemeToLabels() {
        nameLabel.textColor = .white
        nameLabel.attributedPlaceholder = NSAttributedString(string: Const.textFieldPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "BackgroundImageColor") ?? .lightGray])
        infoLabel.textColor = .white
        infoLabel.backgroundColor = .black
    }
    
    private func setNightThemeToButtons() {
        editPhotoButton.backgroundColor = UIColor(named: "OutcomingMessageNightThemeColor")
        setNightThemeToBottomButtons(editButton, cancelButton, saveGCDButton, saveOperationsButton)
    }
    
    private func setNightThemeToBottomButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(named: "OutcomingMessageNightThemeColor")
        }
    }
    
    private func setNightThemeToNavBar() {
        navigationBar.backgroundColor = UIColor(named: "IncomingMessageNightThemeColor")
        navigationBarLabel.textColor = .white
        navigationBarButton.setTitleColor(.systemYellow, for: .normal)
    }
    
    
    private func setEnableStatusToSaveButtons() {
        let someDataDidChanged = infoDidChanged || nameDidChanged || imageDidChanged
        saveGCDButton.isEnabled = someDataDidChanged
        saveOperationsButton.isEnabled = someDataDidChanged
    }
    
    private enum SavingApproach {
        case GCD
        case operations
    }
    
    private enum Const {
        static let buttonBorderRadius: CGFloat = 14
        static let maxNumOfCharsInName = 16
        static let textFieldPlaceholderText = "ФИО"
        static let textViewPlaceholderText = "Расскажите о себе :)"
        static let plistFileName = "ProfileInfo.plist"
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameDidChanged = textField.text != initialName
        setEnableStatusToSaveButtons()
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Const.textViewPlaceholderText
            textView.textColor = UIColor.lightGray
        }
        infoDidChanged = textView.text != initialInfo
        setEnableStatusToSaveButtons()
    }
}

// Все, что связано с установкой фото.
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = image
            imageDidChanged = true
            if !isProfileEditing {
                changeProfileEditingStatus(isEditing: true)
            }
            setEnableStatusToSaveButtons()
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
