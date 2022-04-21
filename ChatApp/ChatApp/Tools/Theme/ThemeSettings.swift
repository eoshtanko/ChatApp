//
//  ThemeSettings.swift
//  ChatApp
//
//  Created by Екатерина on 21.04.2022.
//

import UIKit

// c помощью такого разделения будет легко удалить более не нужны раздел
// или добавить новый

protocol ThemeSettingsProtocol: ProfileThemeProtocol {
    var backgroundColor: UIColor { get }
    var primaryTextColor: UIColor { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var activityIndicatorColor: UIColor { get }
    var navigationBarColor: UIColor { get }
}

// Все, что необходимо для учтановки темы профиля
protocol ProfileThemeProtocol {
    var navigationBarButtonColor: UIColor { get }
    var photoButtonBackgroundColor: UIColor { get }
    var textButtonBackgroundColor: UIColor { get }
    var buttonTextColor: UIColor { get }
}

struct ThemeSettings: ThemeSettingsProtocol, ProfileThemeProtocol {
    // ThemeSettingsProtocol
    let backgroundColor: UIColor
    let primaryTextColor: UIColor
    let keyboardAppearance: UIKeyboardAppearance
    let activityIndicatorColor: UIColor
    let navigationBarColor: UIColor
    // ProfileThemeProtocol
    let navigationBarButtonColor: UIColor
    let photoButtonBackgroundColor: UIColor
    let textButtonBackgroundColor: UIColor
    let buttonTextColor: UIColor
    //
}
