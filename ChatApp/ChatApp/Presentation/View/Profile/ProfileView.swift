//
//  ProfileView.swift
//  ChatApp
//
//  Created by Екатерина on 25.04.2022.
//

import UIKit

// Избавляемся от Massive View Controller
class ProfileView: UIView {
    
    private var activityIndicator: UIActivityIndicatorView?
    
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
    
    func changeProfileEditingStatus(_ isEditing: Bool) {
        changeHiddenPropertyOfButtons(isEditing)
        changeEnablePropertyOfFields(isEditing)
        setSaveButtonIsEnabled(false)
        if isEditing {
            nameLabel.becomeFirstResponder()
        }
    }
    
    func prepareForSaving() {
        setSaveButtonIsEnabled(false)
        cancelButton.isEnabled = false
        editPhotoButton.isEnabled = false
        changeEnablePropertyOfFields(false)
        activityIndicator?.startAnimating()
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
    
    func setSaveButtonIsEnabled(_ isEnabled: Bool) {
        saveGCDButton.isEnabled = isEnabled
    }
    
    func finalizeSaving() {
        cancelButton.isEnabled = true
        editPhotoButton.isEnabled = true
        activityIndicator?.stopAnimating()
    }
    
    func setNameLabel(name: String?) {
        if name != nil {
            nameLabel.text = name
        }
    }
    
    func setInfoLabel(info: String?) {
        if info == nil {
            setHintTextToInfoLabel()
        } else {
            infoLabel.text = info
        }
    }
    
    private func setHintTextToInfoLabel() {
        infoLabel.text = Const.textViewPlaceholderText
        infoLabel.textColor = .lightGray
    }
    
    func setImage(image: UIImage?) {
        if image == nil {
            setDefaultImage(to: profileImageView)
        } else {
            profileImageView.image = image
        }
    }
    
    func configureSubviews() {
        configureProfileImageView()
        configureEditPhotoButton()
        configureActivityIndicator()
        configureNameLabel()
        configureButtons()
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
        activityIndicator?.center = self.center
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.style = .large
        activityIndicator?.transform = CGAffineTransform(scaleX: 3, y: 3)
        if let activityIndicator = activityIndicator {
            self.addSubview(activityIndicator)
        }
    }
    
    func configureNameLabel() {
        nameLabel.attributedPlaceholder = NSAttributedString(string: Const.textFieldPlaceholderText,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    private func configureButtons() {
        configureButtons(editButton, cancelButton, saveGCDButton)
    }
    
    private func configureButtons(_ buttons: UIButton...) {
        for button in buttons {
            button.layer.cornerRadius = Const.buttonBorderRadius
            button.clipsToBounds = true
            button.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    func setCurrentTheme(themeManager: ThemeManagerProtocol) {
        self.backgroundColor = themeManager.themeSettings?.backgroundColor
        setThemeToButtons(themeManager)
        setThemeToNavigationBar(themeManager)
        setEmptyIndicatorColorToInfoLabel(themeManager)
        setEmptyIndicatorColorToNameLabel(themeManager)
    }
    
    private func setThemeToButtons(_ themeManager: ThemeManagerProtocol) {
        editPhotoButton.backgroundColor = themeManager.themeSettings?.photoButtonBackgroundColor
        setThemeToBottomButtons(themeManager, editButton, cancelButton, saveGCDButton)
    }
    
    private func setThemeToBottomButtons(_ themeManager: ThemeManagerProtocol, _ buttons: UIButton...) {
        for button in buttons {
            button.setTitleColor(themeManager.themeSettings?.buttonTextColor, for: .normal)
            button.backgroundColor = themeManager.themeSettings?.textButtonBackgroundColor
        }
    }
    
    private func setThemeToNavigationBar(_ themeManager: ThemeManagerProtocol) {
        navigationBarLabel.textColor = themeManager.themeSettings?.primaryTextColor
        navigationBarButton.setTitleColor(themeManager.themeSettings?.navigationBarButtonColor, for: .normal)
    }
    
    func setEmptyStateToInfoLabel(_ themeManager: ThemeManagerProtocol) {
        infoLabel.text = Const.textViewPlaceholderText
        setEmptyIndicatorColorToInfoLabel(themeManager)
    }
    
    func setEmptyIndicatorColorToNameLabel(_ themeManager: ThemeManagerProtocol) {
        nameLabel.textColor = nameLabel.text?.isEmpty ?? false ? .lightGray : themeManager.themeSettings?.primaryTextColor
    }
    
    private func setEmptyIndicatorColorToInfoLabel(_ themeManager: ThemeManagerProtocol) {
        infoLabel.textColor = infoLabel.text == Const.textViewPlaceholderText ? .lightGray : themeManager.themeSettings?.primaryTextColor
    }
    
    private func setDefaultImage(to imageView: UIImageView) {
        imageView.backgroundColor = UIColor(named: "BackgroundImageColor")
        imageView.tintColor = UIColor(named: "DefaultImageColor")
        imageView.image = UIImage(systemName: "person.fill")
    }
    
    func configureStatusBar(_ style: UIStatusBarStyle, currentTheme: Theme) {
        if currentTheme != .night {
            UIApplication.shared.statusBarStyle = style
        }
    }
    
    private enum Const {
        static let buttonBorderRadius: CGFloat = 14
        static let maxNumOfCharsInName = 40
        static let textFieldPlaceholderText = "ФИО"
        static let textViewPlaceholderText = "Расскажите о себе :)"
    }
}
