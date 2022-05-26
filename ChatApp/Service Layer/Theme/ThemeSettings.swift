//
//  ThemeSettings.swift
//  ChatApp
//
//  Created by Екатерина on 21.04.2022.
//

import UIKit

// c помощью такого разделения будет легко удалить более не нужны раздел
// или добавить новый

// Все, что необходимо для учтановки темы приложения. Общее.
protocol ThemeSettingsProtocol: ProfileThemeProtocol, ThemePickerThemeProtocol, ChatMessageCellThemeProtocol, EnterMessageViewThemeProtocol {
    var backgroundColor: UIColor { get }
    var primaryTextColor: UIColor { get }
    var secondaryTextColor: UIColor { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var activityIndicatorColor: UIColor { get }
    var navigationBarColor: UIColor { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var navigationBarAppearance: UINavigationBarAppearance { get }
    var navigationBarButtonColor: UIColor { get }
}

// Все, что необходимо для учтановки темы профиля
protocol ProfileThemeProtocol {
    var photoButtonBackgroundColor: UIColor { get }
    var textButtonBackgroundColor: UIColor { get }
    var buttonTextColor: UIColor { get }
}

// Все, что необходимо для учтановки темы экрана установки тем
protocol ThemePickerThemeProtocol {
    var themePickerBackgroundColor: UIColor { get }
}

// Все, что необходимо для учтановки темы экрана установки тем
protocol ChatMessageCellThemeProtocol {
    var incomingMessageColor: UIColor { get }
    var outcomingMessageColor: UIColor { get }
}

// Все, что необходимо для учтановки темы панели отправки сообщений
protocol EnterMessageViewThemeProtocol {
    var sendMessageButtonColor: UIColor { get }
    var enterMessageViewBackgroundColor: UIColor { get }
    var enterMessageTextViewBackgroundColor: UIColor { get }
}

struct ThemeSettings: ThemeSettingsProtocol {

    let backgroundColor: UIColor
    let primaryTextColor: UIColor
    let secondaryTextColor: UIColor
    let keyboardAppearance: UIKeyboardAppearance
    let activityIndicatorColor: UIColor
    let navigationBarColor: UIColor
    let statusBarStyle: UIStatusBarStyle
    let navigationBarAppearance: UINavigationBarAppearance
    let navigationBarButtonColor: UIColor
    
    let photoButtonBackgroundColor: UIColor
    let textButtonBackgroundColor: UIColor
    let buttonTextColor: UIColor

    let themePickerBackgroundColor: UIColor
    
    let incomingMessageColor: UIColor
    let outcomingMessageColor: UIColor
    
    let sendMessageButtonColor: UIColor
    let enterMessageViewBackgroundColor: UIColor
    let enterMessageTextViewBackgroundColor: UIColor
}
