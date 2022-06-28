//
//  ThemeManager.swift
//  ChatApp
//
//  Created by Екатерина on 21.04.2022.
//

import UIKit

protocol ThemeManagerProtocol {
    var theme: Theme { get set }
    var themeSettings: ThemeSettingsProtocol? { get }
    func writeThemeToMemory()
    func readThemeFromMemory(completion: ((Result<ApplicationPreferences, Error>) -> Void)?)
}

class ThemeManager: ThemeManagerProtocol {
    
    private let themeSavingServise = SavingServiceAssembly().themeSavingService
    
    // Струтура ответственная за создание тем
    private lazy var themes: ThemesProtocol = Themes()
    
    // Текущая тема
    var theme: Theme {
        didSet {
            switch theme {
            case .classic:
                themeSettings = themes.classicTheme
            case .day:
                themeSettings = themes.dayTheme
            case .night:
                themeSettings = themes.nightTheme
            }
        }
    }
    
    // Пареметры текущей темы
    private(set) var themeSettings: ThemeSettingsProtocol? {
        didSet {
            setTheme(themeSettings: themeSettings ?? themes.classicTheme)
        }
    }
    
    init(theme: Theme) {
        self.theme = theme
    }
    
    func writeThemeToMemory() {
        let preferences = ApplicationPreferences(themeId: theme.rawValue)
        themeSavingServise.saveWithMemoryManager(obj: preferences, complition: nil)
    }
    
    func readThemeFromMemory(completion: ((Result<ApplicationPreferences, Error>) -> Void)?) {
        themeSavingServise.loadWithMemoryManager { result in
            if let result = result {
                completion?(result)
            }
        }
    }
    
    private func setTheme(themeSettings: ThemeSettingsProtocol) {
        UIActivityIndicatorView.appearance().color = themeSettings.activityIndicatorColor
        UITextView.appearance().textColor = themeSettings.primaryTextColor
        UITextView.appearance().backgroundColor = themeSettings.backgroundColor
        UITextField.appearance().textColor = themeSettings.primaryTextColor
        UITextField.appearance().keyboardAppearance = themeSettings.keyboardAppearance
        UINavigationBar.appearance().backgroundColor = themeSettings.navigationBarColor
        UIApplication.shared.statusBarStyle = themeSettings.statusBarStyle
    }
}
