//
//  ThemesView.swift
//  ChatApp
//
//  Created by Екатерина on 25.04.2022.
//

import UIKit

class ThemesView: UIView {
    
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
    
    func setCurrentTheme(themeManager: ThemeManagerProtocol,
                         navigationItem: UINavigationItem,
                         navigationController: UINavigationController?,
                         currentTheme: Theme, previousTheme: Theme) {
        setUnselectedStateToThemeView(previousTheme: previousTheme)
        setSelectedStateToThemeView(currentTheme: currentTheme)
        configureBackground(themeManager)
        configureNavigationBar(navigationItem, navigationController, themeManager)
    }
    
    func configureView(themeManager: ThemeManagerProtocol, theme: Theme, navigationItem: UINavigationItem, navigationController: UINavigationController?) {
        configureThemeButtons(themeManager, theme)
        setCurrentTheme(themeManager: themeManager, navigationItem: navigationItem,
                        navigationController: navigationController,
                        currentTheme: theme, previousTheme: theme)
    }
    
    private func configureBackground(_ themeManager: ThemeManagerProtocol) {
        self.backgroundColor = themeManager.themeSettings?.themePickerBackgroundColor
    }
    
    private func configureThemeButtons(_ themeManager: ThemeManagerProtocol, _ theme: Theme) {
        roundOffEdges(classicThemeArea, classicThemeIncomingMessage, classicThemeOutcomingMessage,
                      dayThemeArea, dayThemeIncomingMessage, dayThemeOutcomingMessage,
                      nightThemeArea, nightThemeIncomingMessage, nightThemeOutcomingMessage)
        
        setUnselectedStateToThemeViews(classicThemeArea, dayThemeArea, nightThemeArea)
    }
    
    private func roundOffEdges(_ views: UIView...) {
        for view in views {
            view.layer.cornerRadius = Const.viewsCornerRadius
        }
    }
    
    private func configureNavigationBar(_ navigationItem: UINavigationItem,
                                        _ navigationController: UINavigationController?,
                                        _ themeManager: ThemeManagerProtocol) {
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .never
        setThemeToNavigationBar(navigationItem, navigationController, themeManager)
    }
    
    private func setThemeToNavigationBar(_ navigationItem: UINavigationItem,
                                         _ navigationController: UINavigationController?,
                                         _ themeManager: ThemeManagerProtocol) {
        navigationItem.standardAppearance = themeManager.themeSettings?.navigationBarAppearance
        navigationController?.navigationBar.tintColor = themeManager.themeSettings?.navigationBarButtonColor
    }
    
    private func setSelectedStateToThemeView(currentTheme: Theme) {
        var selectedView: UIView
        switch currentTheme {
        case .classic:
            selectedView = classicThemeArea
        case .day:
            selectedView = dayThemeArea
        case .night:
            selectedView = nightThemeArea
        }
        setSelectedState(to: selectedView)
    }
    
    private func setSelectedState(to selectedView: UIView) {
        selectedView.layer.borderWidth = Const.viewsBorderWidthSelected
        selectedView.layer.borderColor = CGColor(red: 0.145, green: 0.482, blue: 0.980, alpha: 1)
    }
    
    private func setUnselectedStateToThemeView(previousTheme: Theme) {
        switch previousTheme {
        case .classic:
            setUnselectedStateToThemeViews(classicThemeArea)
        case .day:
            setUnselectedStateToThemeViews(dayThemeArea)
        case .night:
            setUnselectedStateToThemeViews(nightThemeArea)
        }
    }
    
    private func setUnselectedStateToThemeViews(_ views: UIView...) {
        for view in views {
            view.layer.borderWidth = Const.viewsBorderWidthNotSelected
            view.layer.borderColor = CGColor(gray: 0.5, alpha: 0.5)
        }
    }
    
    func getNavigationButton(_ themeManager: ThemeManagerProtocol) -> UIButton {
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(themeManager.themeSettings?.navigationBarButtonColor, for: .normal)
        return cancelButton
    }
    
    private enum Const {
        static let viewsCornerRadius: CGFloat = 20
        static let viewsBorderWidthNotSelected: CGFloat = 1.5
        static let viewsBorderWidthSelected: CGFloat = 4
    }
}
