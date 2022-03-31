//
//  ThemesViewController.swift
//  ChatApp
//
//  Created by Екатерина on 16.03.2022.
//

import UIKit

class ThemesViewController: UIViewController {
    
    // Retain Cycle
    // Если бы мы не сделали ссылку weak, возник бы retain cycle.
    // Так как в ConversationsListViewController (ThemesPickerDelegate) есть сильная ссылка
    // на ThemesViewController:
    // var themesViewController: ThemesViewController?
    weak var themesPickerDelegate: ThemesPickerDelegate?
    
    // Retain Cycle
    // Как оговаривалось на лекции, замыкания могут приводить к retain cycle.
    // У нашего замыкания есть список захвата, в нем мы захватываем self ConversationsListViewController
    // Мы были на лекции и поэтому в список захвата добавили weak ([weak self]), но если бы мы этого не сделали
    // возник бы retain cycle.
    var pickeTheme: ((Theme) -> Void)?
    
    private var initialTheme: Theme = .classic
    private var previousTheme: Theme = .classic
    private var currentTheme: Theme = .classic
    
    private let appearance = UINavigationBarAppearance()
    
    @IBOutlet weak var classicThemeArea: UIView!
    @IBOutlet weak var classicThemeIncomingMessage: UIView!
    @IBOutlet weak var classicThemeOutcomingMessage: UIView!
    @IBOutlet weak var classicThemeLabel: UILabel!
    
    @IBOutlet weak var dayThemeArea: UIView!
    @IBOutlet weak var dayThemeIncomingMessage: UIView!
    @IBOutlet weak var dayThemeOutcomingMessage: UIView!
    @IBOutlet weak var dayThemeLabel: UILabel!
    
    @IBOutlet weak var nightThemeArea: UIView!
    @IBOutlet weak var nightThemeIncomingMessage: UIView!
    @IBOutlet weak var nightThemeOutcomingMessage: UIView!
    @IBOutlet weak var nightThemeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialTheme = currentTheme
    }
    
    init?(coder: NSCoder, themesPickerDelegate: ThemesPickerDelegate?, theme: Theme, pickeThemeMethod: ((Theme) -> Void)?) {
        self.themesPickerDelegate = themesPickerDelegate
        self.pickeTheme = pickeThemeMethod
        previousTheme = theme
        currentTheme = theme
        super.init(coder: coder)
    }
    
    func setCurrentTheme(_ theme: Theme) {
        previousTheme = currentTheme
        currentTheme = theme
        if classicThemeArea != nil {
            setUnselectedStateToThemeView()
            setSelectedStateToThemeView()
            configureBackground()
            configureNavigationBar()
        }
    }
    
    private func configureView() {
        configureBackground()
        configureThemeButtons()
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .never
        setThemeToNavigationBar()
        configureNavigationBarButton()
    }
    
    private func setThemeToNavigationBar() {
        appearance.titleTextAttributes = currentTheme == .night ? [.foregroundColor: UIColor.white] : [.foregroundColor: UIColor.black]
        appearance.backgroundColor = currentTheme == .night ? .black : UIColor(named: "BackgroundNavigationBarColor")
        navigationItem.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = currentTheme == .night ? .systemYellow : .systemBlue
    }
    
    private func configureNavigationBarButton() {
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(currentTheme == .night ? .systemYellow : .systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(changeToInitialTheme), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }
    
    @objc private func changeToInitialTheme(_ sender: UITapGestureRecognizer? = nil) {
        changeTheme(to: initialTheme)
    }
    
    private func configureBackground() {
        switch currentTheme {
        case .classic:
            view.backgroundColor = UIColor(named: "BackgroundClassicThemeColor")
        case .day:
            view.backgroundColor = UIColor(named: "BackgroundDayThemeColor")
        case .night:
            view.backgroundColor = UIColor(named: "BackgroundNightThemeColor")
        }
    }
    
    private func configureThemeButtons() {
        roundOffEdges(classicThemeArea, classicThemeIncomingMessage, classicThemeOutcomingMessage,
                      dayThemeArea, dayThemeIncomingMessage, dayThemeOutcomingMessage,
                      nightThemeArea, nightThemeIncomingMessage, nightThemeOutcomingMessage)
        
        setUnselectedStateToThemeViews(classicThemeArea, dayThemeArea, nightThemeArea)
        setCurrentTheme(currentTheme)
        addGestureRecognizers()
    }
    
    private func roundOffEdges(_ views: UIView...) {
        for view in views {
            view.layer.cornerRadius = Const.viewsCornerRadius
        }
    }
    
    private func setUnselectedStateToThemeViews(_ views: UIView...) {
        for view in views {
            view.layer.borderWidth = Const.viewsBorderWidthNotSelected
            view.layer.borderColor = CGColor(gray: 0.5, alpha: 0.5)
        }
    }
    
    private func addGestureRecognizers() {
        addGestureRecognizers(classicThemeArea, classicThemeLabel, .classic)
        addGestureRecognizers(dayThemeArea, dayThemeLabel, .day)
        addGestureRecognizers(nightThemeArea, nightThemeLabel, .night)
    }
    
    private func addGestureRecognizers(_ view: UIView, _ label: UILabel, _ theme: Theme) {
        var selector: Selector?
        switch theme {
        case .classic:
            selector = #selector(self.changeToClassicTheme(_:))
        case .day:
            selector = #selector(self.changeToDayTheme(_:))
        case .night:
            selector = #selector(self.changeToNightTheme(_:))
        }
        let labelTap = UITapGestureRecognizer(target: self, action: selector)
        let viewTap = UITapGestureRecognizer(target: self, action: selector)
        label.addGestureRecognizer(labelTap)
        view.addGestureRecognizer(viewTap)
    }
    
    @objc private func changeToClassicTheme(_ sender: UITapGestureRecognizer? = nil) {
        changeTheme(to: .classic)
    }
    
    @objc private func changeToDayTheme(_ sender: UITapGestureRecognizer? = nil) {
        changeTheme(to: .day)
    }
    
    @objc private func changeToNightTheme(_ sender: UITapGestureRecognizer? = nil) {
        changeTheme(to: .night)
    }
    
    private func changeTheme(to theme: Theme) {
        setCurrentTheme(theme)
        themesPickerDelegate?.selectTheme(theme)
        if let pickeTheme = pickeTheme {
            pickeTheme(theme)
        }
    }
    
    private func setSelectedStateToThemeView() {
        var selectedView: UIView
        switch currentTheme {
        case .classic:
            selectedView = classicThemeArea
        case .day:
            selectedView = dayThemeArea
        case .night:
            selectedView = nightThemeArea
        }
        selectedView.layer.borderWidth = Const.viewsBorderWidthSelected
        selectedView.layer.borderColor = CGColor(red: 0.145, green: 0.482, blue: 0.980, alpha: 1)
    }
    
    private func setUnselectedStateToThemeView() {
        switch previousTheme {
        case .classic:
            setUnselectedStateToThemeViews(classicThemeArea)
        case .day:
            setUnselectedStateToThemeViews(dayThemeArea)
        case .night:
            setUnselectedStateToThemeViews(nightThemeArea)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Const {
        static let viewsCornerRadius: CGFloat = 20
        static let viewsBorderWidthNotSelected: CGFloat = 1.5
        static let viewsBorderWidthSelected: CGFloat = 4
    }
}
