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
        if !saveGCDButton.isEnabled && isEnabled {
            saveGCDButton.isEnabled = isEnabled
            saveGCDButton.animateShaking(xOffset: 5, yOffset: 5, rotationAngleDegrees: 18, duration: 0.3)
        } else if saveGCDButton.isEnabled && !isEnabled {
            saveGCDButton.isEnabled = isEnabled
            saveGCDButton.animateStopShaking()
        }
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
        nameLabel.attributedPlaceholder = NSAttributedString(
            string: Const.textFieldPlaceholderText,
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
        guard let theme = themeManager.themeSettings else {
            return
        }
        self.backgroundColor = theme.backgroundColor
        infoLabel.keyboardAppearance = theme.keyboardAppearance
        setThemeToButtons(theme)
        setThemeToNavigationBar(theme)
        setEmptyIndicatorColorToInfoLabel(themeManager)
        setEmptyIndicatorColorToNameLabel(themeManager)
    }
    
    private func setThemeToButtons(_ theme: ThemeSettingsProtocol) {
        editPhotoButton.backgroundColor = theme.photoButtonBackgroundColor
        setThemeToBottomButtons(theme, editButton, cancelButton, saveGCDButton)
    }
    
    private func setThemeToBottomButtons(_ theme: ThemeSettingsProtocol, _ buttons: UIButton...) {
        for button in buttons {
            button.setTitleColor(theme.buttonTextColor, for: .normal)
            button.backgroundColor = theme.textButtonBackgroundColor
        }
    }
    
    private func setThemeToNavigationBar(_ theme: ThemeSettingsProtocol) {
        navigationBarLabel.textColor = theme.primaryTextColor
        navigationBarButton.setTitleColor(theme.navigationBarButtonColor, for: .normal)
    }
    
    func setEmptyStateToInfoLabel(_ themeManager: ThemeManagerProtocol) {
        infoLabel.text = Const.textViewPlaceholderText
        setEmptyIndicatorColorToInfoLabel(themeManager)
    }
    
    func setEmptyIndicatorColorToNameLabel(_ themeManager: ThemeManagerProtocol) {
        nameLabel.textColor = nameLabel.text?.isEmpty ?? false ? .lightGray : themeManager.themeSettings?.primaryTextColor
    }
    
    func setEmptyIndicatorColorToInfoLabel(_ themeManager: ThemeManagerProtocol) {
        infoLabel.textColor = infoLabel.text == Const.textViewPlaceholderText ? .lightGray : themeManager.themeSettings?.primaryTextColor
    }
    
    private func setDefaultImage(to imageView: UIImageView) {
        imageView.backgroundColor = UIColor(named: "BackgroundImageColor")
        imageView.tintColor = UIColor(named: "DefaultImageColor")
        imageView.image = UIImage(systemName: "person.fill")
    }
    
    private enum Const {
        static let buttonBorderRadius: CGFloat = 14
        static let maxNumOfCharsInName = 40
        static let textFieldPlaceholderText = "ФИО"
        static let textViewPlaceholderText = "Расскажите о себе :)"
    }
}

extension UINavigationController {
    
    func setStatusBarColor(_ backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
}
