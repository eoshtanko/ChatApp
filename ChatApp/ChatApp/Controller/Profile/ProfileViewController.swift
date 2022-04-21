//
//  ViewController.swift
//  ChatApp
//
//  Created by Екатерина on 22.02.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    weak var conversationsListViewController: ConversationsListViewController?
    private var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    
    var currentTheme: Theme = .classic {
        didSet {
            setCurrentTheme()
        }
    }
    
    var isProfileEditing: Bool = false
    var imageDidChanged = false
    var initialImage: UIImage?
    var infoDidChanged = false
    var initialInfo: String?
    private var nameDidChanged = false
    private var initialName: String?
    
    private let GCDMemoryManager = GCDMemoryManagerInterface<User>()
    private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveGCDButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLabel: UILabel!
    @IBOutlet weak var navigationBarButton: UIButton!
    @IBOutlet weak var buttonVerticalStackView: UIStackView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        setInitialProfileData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureProfileImageView()
        configureEditPhotoButton()
        configureInfoLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureStatusBar(.lightContent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configureStatusBar(.darkContent)
    }
    
    func setCurrentTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    private func handleSaveToMemoryRequestResult(result: Result<User, Error>?) {
        DispatchQueue.main.async { [weak self] in
            self?.finalizeSaving()
            switch result {
            case .success(let user):
                self?.handleSuccessSaveToMemoryRequestResult(user)
            case .failure, .none:
                self?.handleFailureSaveToMemoryRequestResult()
            }
        }
    }
    
    private func handleSuccessSaveToMemoryRequestResult(_ user: User) {
        CurrentUser.user = user
        conversationsListViewController?.configureRightNavigationButton()
        showSuccessAlert()
    }
    
    private func showSuccessAlert() {
        let successAlert = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: UIAlertController.Style.alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in
            self.changeProfileEditingStatus(isEditing: false)
        })
        present(successAlert, animated: true, completion: nil)
    }
    
    private func handleFailureSaveToMemoryRequestResult() {
        returnToInitialData()
        showFailureAlert()
    }
    
    private func showFailureAlert() {
        let failureAlert = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные.", preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {_ in
            self.changeProfileEditingStatus(isEditing: false)
        })
        failureAlert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel) {_ in
            self.saveViaGCD()
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func finalizeSaving() {
        cancelButton.isEnabled = true
        editPhotoButton.isEnabled = true
        activityIndicator.stopAnimating()
    }
    
    func changeProfileEditingStatus(isEditing: Bool) {
        changeHiddenPropertyOfButtons(isEditing)
        isProfileEditing = isEditing
        changeEnablePropertyOfFields(isEditing)
        disableSaveButtons()
        setInitialData()
        if isEditing {
            nameLabel.becomeFirstResponder()
        } else {
            resetChangeIndicators()
        }
    }
    
    private func changeEnablePropertyOfFields(_ isEditing: Bool) {
        nameLabel.isUserInteractionEnabled = isEditing
        infoLabel.isUserInteractionEnabled = isEditing
    }
    
    private func changeHiddenPropertyOfButtons(_ isEditing: Bool) {
        editButton.isHidden = isEditing
        cancelButton.isHidden = !isEditing
        saveGCDButton.isHidden = !isEditing
    }
    
    private func disableSaveButtons() {
        saveGCDButton.isEnabled = false
    }
    
    private func setInitialData() {
        initialName = nameLabel.text
        initialInfo = infoLabel.textColor == .lightGray ? "" : infoLabel.text
        initialImage = profileImageView.image
    }
    
    private func resetChangeIndicators() {
        infoDidChanged = false
        nameDidChanged = false
        imageDidChanged = false
    }
    
    private func saveViaGCD() {
        prepareForSaving()
        saveWithMemoryManager(memoryManager: GCDMemoryManager)
    }
    
    private func saveWithMemoryManager<M: MemoryManagerProtocol>(memoryManager: M) {
        if let objectToWrite = getUserWithUpdatedData() as? M.MemoryObject {
            memoryManager.writeDataToMemory(fileName: FileNames.plistFileNameForProfileInfo, objectToWrite: objectToWrite) { [weak self] result in
                self?.handleSaveToMemoryRequestResult(result: result as? Result<User, Error>)
            }
        }
    }
    
    private func getUserWithUpdatedData() -> User {
        return User(name: nameLabel.text, info: getInfo(), imageData: getDataFromImage(), id: CurrentUser.user.id)
    }
    
    private func getInfo() -> String? {
        guard infoLabel.textColor != .lightGray else {
            return nil
        }
        return infoLabel.text
    }
    
    private func getDataFromImage() -> Data? {
        if !imageDidChanged {
            return CurrentUser.user.imageData
        }
        var image: Data?
        if let profileImageViewImage = profileImageView.image {
            image = profileImageViewImage.pngData()
        }
        return image
    }
    
    private func prepareForSaving() {
        disableSaveButtons()
        cancelButton.isEnabled = false
        editPhotoButton.isEnabled = false
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
    
    private func configureSubviews() {
        configureNameLabel()
        configureActivityIndicator()
        configureButtons(editButton, cancelButton, saveGCDButton)
    }
    
    private func configureNameLabel() {
        nameLabel.delegate = self
        nameLabel.addTarget(self, action: #selector(nameLabelDidChange), for: .editingChanged)
        nameLabel.attributedPlaceholder = NSAttributedString(string: Const.textFieldPlaceholderText,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @objc private func nameLabelDidChange() {
        nameDidChanged = nameLabel.text != initialName
        setEmptyIndicatorColorToNameLabel()
        setEnableStatusToSaveButtons()
    }
    
    private func configureInfoLabel() {
        infoLabel.delegate = self
    }
    
    private func configureButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.layer.cornerRadius = Const.buttonBorderRadius
            button.clipsToBounds = true
            button.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    private func setInitialProfileData() {
        setInitialImage()
        setInitialName()
        setInitialInfo()
    }
    
    private func setInitialImage() {
        if let data = CurrentUser.user.imageData, let image = UIImage(data: data) {
            profileImageView.image = image
        }
    }
    
    private func setInitialName() {
        if CurrentUser.user.name != nil {
            nameLabel.text = CurrentUser.user.name
        }
    }
    
    private func setInitialInfo() {
        if CurrentUser.user.info != nil {
            infoLabel.text = CurrentUser.user.info
        } else {
            infoLabel.text = Const.textViewPlaceholderText
            infoLabel.textColor = .lightGray
        }
    }
    
    private func configureProfileImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
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
    
    private func configureStatusBar(_ style: UIStatusBarStyle) {
        if currentTheme != .night {
            UIApplication.shared.statusBarStyle = style
        }
    }
    
    private func setCurrentTheme() {
        themeManager.theme = currentTheme
        view.backgroundColor = themeManager.themeSettings?.backgroundColor
        setThemeToButtons()
        setThemeToNavigationBar()
        setEmptyIndicatorColorToInfoLabel()
        setEmptyIndicatorColorToNameLabel()
    }
    
    private func setThemeToButtons() {
        editPhotoButton.backgroundColor = themeManager.themeSettings?.photoButtonBackgroundColor
        setThemeToBottomButtons(editButton, cancelButton, saveGCDButton)
    }
    
    private func setThemeToBottomButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.setTitleColor(themeManager.themeSettings?.buttonTextColor, for: .normal)
            button.backgroundColor = themeManager.themeSettings?.textButtonBackgroundColor
        }
    }
    
    private func setThemeToNavigationBar() {
        navigationBarLabel.textColor = themeManager.themeSettings?.primaryTextColor
        navigationBarButton.setTitleColor(themeManager.themeSettings?.navigationBarButtonColor, for: .normal)
    }
    
    func setEmptyIndicatorColorToNameLabel() {
        nameLabel.textColor = nameLabel.text?.isEmpty ?? false ? .lightGray : themeManager.themeSettings?.primaryTextColor
    }
    
    func setEmptyIndicatorColorToInfoLabel() {
        infoLabel.textColor = infoLabel.text == Const.textViewPlaceholderText ? .lightGray : themeManager.themeSettings?.primaryTextColor
    }
    
    func setEnableStatusToSaveButtons() {
        let someDataDidChanged = infoDidChanged || nameDidChanged || imageDidChanged
        saveGCDButton.isEnabled = someDataDidChanged
    }
    
    enum Const {
        static let buttonBorderRadius: CGFloat = 14
        static let maxNumOfCharsInName = 40
        static let textFieldPlaceholderText = "ФИО"
        static let textViewPlaceholderText = "Расскажите о себе :)"
    }
}
