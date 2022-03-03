//
//  ViewController.swift
//  ChatApp
//
//  Created by Екатерина on 22.02.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBAction func editPhotoButtonPressed(_ sender: Any) {
        print("Выбери изображение профиля")
        pickImage()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Если мы попытаемся распечатать frame saveButton
        // print(saveButton.frame)
        // то столкнемся со следующей ошибкой:
        // Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value
        // Все потому, что на данном этапе saveButton все еще не инициализирован и равен nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        print("viewDidLoad button frame: \(saveButton.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // frame кнопки во viewDidAppear отличается от fram-а в viewDidLoad:
        // viewDidLoad button frame: (56.0, 478.0, 208.0, 40.0)
        // viewDidAppear button frame: (56.0, 626.0, 302.0, 40.0)
        //
        // Сейчас у нас в storyboard выбрано устройство iPhone SE
        // Значения frame во viewDidLoad соответствуют этому устройству
        // (Именно в iPhone SE игрек кнопки будет 478.0, а ширина - 208.0)
        //
        // Запускаем приложение мы на симуляторе iPhone 8 Plus.
        // Значения frame во viewDidAppear соответствуют этому устройству
        // (Именно в iPhone 8 Plus игрек кнопки будет 626.0, а ширина - 302.0)
        //
        // Происходит так, потому что во viewDidLoad контроллер только что загрузил
        // из nib-файла иерархию представлений в память, и все представления соответствуют созданным нами
        // в storyboard.
        // viewDidAppear же вызывается, когда вьюшка контроллера полностью перемещается на экран.
        // (Called when the view controller’s view is fully transitioned onto the screen)
        // И соответственно значения frame-a соответствуют устройству, на котором приложение запущено.
        print("viewDidAppear button frame: \(saveButton.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubviews()
    }
    
    private func configureSubviews() {
        let buttonBorderRadius: CGFloat = 14
        saveButton.layer.cornerRadius = buttonBorderRadius
        saveButton.clipsToBounds = true
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        
        editPhotoButton.layer.cornerRadius = editPhotoButton.frame.size.width / 2
        editPhotoButton.clipsToBounds = true
    }
}

// Все, что связано с UITextField.
extension ProfileViewController: UITextFieldDelegate {
    
    private static let maxNumOfCharsInName = 20
    
    // Ввожу ограничение на максимальное количество символов в имени.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxNumOfCharsInName = 20
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= maxNumOfCharsInName
    }
}

// Navigation bar.
extension ProfileViewController {
    
    private func configureNavigationBar() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "BackgroundNavigationBarColor")
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Const.hightOfNavigationBar)
        navigationBar.clipsToBounds = true
        
        let customTitleView = createCustomTitleView(titleName: "My Profile")
        let customButton = createCustomButton()
        
        let navigationItem = UINavigationItem()
        navigationItem.titleView = customTitleView
        navigationItem.rightBarButtonItem = customButton
        navigationBar.setItems([navigationItem], animated: false)
        
        self.view.addSubview(navigationBar)
    }
    
    private func createCustomTitleView(titleName: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: Const.hightOfNavigationBar))
        
        let titleLabel = UILabel()
        titleLabel.text = "My Profile"
        titleLabel.frame = CGRect(x: Const.leadigSpaceOfTitleLabel,
                                  y: view.center.y - Const.hightOfTitleLabel / 2,
                                  width: Const.widthOfTitleLabel,
                                  height: Const.hightOfTitleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: Const.fontSizeOfTitleLabel, weight: .bold)
        titleLabel.textColor = .black
        
        view.addSubview(titleLabel)
        return view
    }
    
    private func createCustomButton() -> UIBarButtonItem {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: Const.hightOfNavigationBar))
        let button = UIButton(type: .system)
        button.frame = CGRect(x: view.frame.width - Const.trailingSpaceOfCloseButton - Const.widthOfCloseButton,
                              y: view.center.y - Const.hightOfCloseButton / 2,
                              width: Const.widthOfCloseButton,
                              height: Const.hightOfCloseButton)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Const.fontSizeOfCloseButton, weight: .semibold)
        button.setTitle("Close", for: .normal)
        
        view.addSubview(button)
        return UIBarButtonItem(customView: view)
    }
    
    private enum Const {
        static let hightOfNavigationBar: CGFloat = 96
        static let hightOfTitleLabel : CGFloat = 32
        static let hightOfCloseButton : CGFloat = 35
        static let widthOfTitleLabel : CGFloat = 122
        static let widthOfCloseButton : CGFloat = 69
        static let leadigSpaceOfTitleLabel : CGFloat = 16
        static let trailingSpaceOfCloseButton : CGFloat = 17
        
        static let fontSizeOfTitleLabel : CGFloat = 26
        static let fontSizeOfCloseButton : CGFloat = 17
    }
}

// Все, что связано с установкой фото.
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = image
        } else {
            self.showAlertWith(message: "No image found.")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true)
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


