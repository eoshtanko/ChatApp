//
//  ViewController.swift
//  ChatApp
//
//  Created by Екатерина on 22.02.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var profileView: ProfileView?
    
    weak var interactiveCircleTransition: CircleInteractiveTransition?
    
    let requestSender = RequestSender()
    
    var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
        }
    }
    
    private let userSavingService = SavingServiceAssembly().userSavingService
    
    weak var conversationsListViewController: ConversationsListViewController?
    
    var isProfileEditing: Bool = false
    var imageDidChanged = false
    var initialImage: UIImage?
    var infoDidChanged = false
    var initialInfo: String?
    private var nameDidChanged = false
    private var initialName: String?
    
    @IBAction func editPhotoButtonPressed(_ sender: Any) {
        pickImage()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
        interactiveCircleTransition?.finish()
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
        configureSubviewDelegetes()
        setInitialProfileData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileView?.configureSubviews()
        profileView?.setCurrentTheme(themeManager: themeManager)
    }
    
    func setCurrentTheme(_ theme: Theme) {
        currentTheme = theme
    }
    
    private func configureSubviewDelegetes() {
        configureNameLabelDelegate()
        configureInfoLabelDelegate()
    }
    
    private func configureNameLabelDelegate() {
        profileView?.nameLabel.delegate = self
        profileView?.nameLabel.addTarget(self, action: #selector(nameLabelDidChange), for: .editingChanged)
    }
    
    @objc private func nameLabelDidChange() {
        nameDidChanged = profileView?.nameLabel.text != initialName
        profileView?.setEmptyIndicatorColorToNameLabel(themeManager)
        setEnableStatusToSaveButtons()
    }
    
    func setEnableStatusToSaveButtons() {
        let someDataDidChanged = infoDidChanged || nameDidChanged || imageDidChanged
        profileView?.setSaveButtonIsEnabled(someDataDidChanged)
    }
    
    private func configureInfoLabelDelegate() {
        profileView?.infoLabel.delegate = self
    }
    
    func setInitialProfileData() {
        profileView?.setNameLabel(name: CurrentUser.user.name)
        profileView?.setInfoLabel(info: CurrentUser.user.info)
        setInitialImage()
    }
    
    private func setInitialImage() {
        if let data = CurrentUser.user.imageData, let image = UIImage(data: data) {
            profileView?.setImage(image: image)
        }
    }
    
    func changeProfileEditingStatus(isEditing: Bool) {
        isProfileEditing = isEditing
        profileView?.changeProfileEditingStatus(isEditing)
        setInitialData()
        if !isEditing {
            resetChangeIndicators()
        }
    }
    
    func setInitialData() {
        initialName = profileView?.nameLabel.text
        initialInfo = profileView?.infoLabel.textColor == .lightGray ? "" : profileView?.infoLabel.text
        initialImage = profileView?.profileImageView.image
    }
    
    private func resetChangeIndicators() {
        infoDidChanged = false
        nameDidChanged = false
        imageDidChanged = false
    }
    
    private func saveViaGCD() {
        profileView?.prepareForSaving()
        userSavingService.saveWithMemoryManager(obj: getUserWithUpdatedData(), complition: handleSaveToMemoryRequestResult)
    }
    
    private func getUserWithUpdatedData() -> User {
        return User(name: profileView?.nameLabel.text, info: getInfo(), imageData: getImage(), id: CurrentUser.user.id)
    }
    
    private func getInfo() -> String? {
        guard profileView?.infoLabel?.textColor != .lightGray else {
            return nil
        }
        return profileView?.infoLabel?.text
    }
    
    private func getImage() -> Data? {
        if !imageDidChanged {
            return CurrentUser.user.imageData
        }
        var image: Data?
        if let profileImageViewImage = profileView?.profileImageView.image {
            image = profileImageViewImage.pngData()
        }
        return image
    }
    
    private func handleSaveToMemoryRequestResult(result: Result<User, Error>?) {
        DispatchQueue.main.async { [weak self] in
            self?.profileView?.finalizeSaving()
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
    
    private func handleFailureSaveToMemoryRequestResult() {
        showFailureAlert()
    }
    
    private func showSuccessAlert() {
        let successAlert = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: UIAlertController.Style.alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [weak self] _ in
            self?.changeProfileEditingStatus(isEditing: false)
        })
        present(successAlert, animated: true, completion: nil)
    }
    
    private func showFailureAlert() {
        let failureAlert = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные.", preferredStyle: UIAlertController.Style.alert)
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [weak self] _ in
            self?.returnToInitialData()
            self?.changeProfileEditingStatus(isEditing: false)
        })
        failureAlert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel) { [weak self] _ in
            self?.saveViaGCD()
        })
        present(failureAlert, animated: true, completion: nil)
    }
    
    private func returnToInitialData() {
        if nameDidChanged {
            profileView?.setNameLabel(name: initialName)
        }
        if infoDidChanged {
            profileView?.setInfoLabel(info: initialInfo)
        }
        if imageDidChanged {
            profileView?.setImage(image: initialImage)
        }
    }
    
    enum Const {
        static let maxNumOfCharsInName = 40
    }
}
