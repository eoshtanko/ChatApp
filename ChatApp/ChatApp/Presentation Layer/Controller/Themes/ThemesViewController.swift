//
//  ThemesViewController.swift
//  ChatApp
//
//  Created by Екатерина on 16.03.2022.
//

import UIKit

class ThemesViewController: UIViewController {

    @IBOutlet var themesView: ThemesView?
    
    private var themeManager: ThemeManagerProtocol = ThemeManager(theme: .classic)
    private var currentTheme: Theme = .classic {
        didSet {
            themeManager.theme = currentTheme
        }
    }
    
    private var pickeTheme: ((Theme) -> Void)?
    private var initialTheme: Theme = .classic
    private var previousTheme: Theme = .classic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themesView?.configureView(themeManager: themeManager, theme: currentTheme,
                                  navigationItem: navigationItem,
                                  navigationController: navigationController)
        addGestureRecognizers()
        initialTheme = currentTheme
        setCurrentTheme(currentTheme)
        configureNavigationBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialTheme = currentTheme
    }
    
    init?(coder: NSCoder, theme: Theme, pickeThemeMethod: ((Theme) -> Void)?) {
        self.pickeTheme = pickeThemeMethod
        previousTheme = theme
        currentTheme = theme
        super.init(coder: coder)
    }
    
    func setCurrentTheme(_ theme: Theme) {
        previousTheme = currentTheme
        currentTheme = theme
        configureNavigationBarButton()
        themesView?.setCurrentTheme(themeManager: themeManager,
                                    navigationItem: navigationItem,
                                    navigationController: navigationController,
                                    currentTheme: currentTheme, previousTheme: previousTheme)
    }
    
    private func configureNavigationBarButton() {
        if let cancelButton = themesView?.getNavigationButton(themeManager) {
            cancelButton.addTarget(self, action: #selector(changeToInitialTheme(_:)), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        }
    }
    
    @objc private func changeToInitialTheme(_ sender: UITapGestureRecognizer? = nil) {
        changeTheme(to: initialTheme)
    }
    
    private func addGestureRecognizers() {
        if let themesView = themesView {
            addGestureRecognizers(themesView.classicThemeArea, themesView.classicThemeLabel, .classic)
            addGestureRecognizers(themesView.dayThemeArea, themesView.dayThemeLabel, .day)
            addGestureRecognizers(themesView.nightThemeArea, themesView.nightThemeLabel, .night)
        }
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
        labelTap.delegate = self
        let viewTap = UITapGestureRecognizer(target: self, action: selector)
        viewTap.delegate = self
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
        if let pickeTheme = pickeTheme {
            pickeTheme(theme)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
