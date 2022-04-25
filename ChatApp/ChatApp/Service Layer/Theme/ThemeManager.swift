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
    
    private let memoryManager = GCDMemoryManagerInterface<ApplicationPreferences>()
    
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
            writeThemeToMemory()
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
        memoryManager.writeDataToMemory(
            fileName: FileNames.plistFileNameForPreferences,
            objectToWrite: preferences, completion: nil)
    }
    
    func readThemeFromMemory(completion: ((Result<ApplicationPreferences, Error>) -> Void)?) {
        memoryManager.readDataFromMemory(fileName: FileNames.plistFileNameForPreferences) { result in
            completion?(result)
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

// Я сомневалась как организовать это лучше:

// 1. Сделать протокол, соответствующий теме:
// protocol ThemeSettings {
//    var backgroundColor: UIColor {get}
//    var primaryTextColor: UIColor {get}
//    var keyboardAppearance: UIKeyboardAppearance {get}
//    var activityIndicatorColor: UIColor {get}
//    var navigationBarColor: UIColor {get}
// }
// Для темы чата, можно было бы сделать отдельный протокол.
//
// И под каждую тему создать свою струтуру:
// struct LightTheme: ThemeSettings {
//    var backgroundColor: UIColor {
//        .white
//    }
//
//    var primaryTextColor: UIColor {
//        .black
//    }
//
//    var keyboardAppearance: UIKeyboardAppearance {
//        .light
//    }
//
//    var activityIndicatorColor: UIColor {
//        .darkGray
//    }
//
//    var navigationBarColor: UIColor {
//        UIColor(named: "BackgroundNavigationBarColor") ?? .white
//    }
// }
// Это сделало бы класс ThemeManager более соответствующим принципу Open Closed, но
// Но у меня возмникли сомнени, правильно ли делать структуру под каждую тему. Ведь в теме не
// содержится логики, это просто занчения...

// 2. Сделать структуру
// struct ThemeSettings {
//    let backgroundColor: UIColor
//    let primaryTextColor: UIColor
//    let keyboardAppearance: UIKeyboardAppearance
//    let activityIndicatorColor: UIColor
//    let navigationBarColor: UIColor
// }
// И в классе ThemeManager создать все темы в виде констант:
// let classicTheme = ThemeSettings(
//    backgroundColor: .white,
//    primaryTextColor: .black,
//    keyboardAppearance: .light,
//    activityIndicatorColor: .darkGray,
//    navigationBarColor: UIColor(named: "BackgroundNavigationBarColor") ?? .lightGray)
