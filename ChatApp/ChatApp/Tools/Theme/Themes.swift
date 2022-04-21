//
//  Themes.swift
//  ChatApp
//
//  Created by Екатерина on 21.04.2022.
//

import UIKit

enum Theme: Int {
    case classic
    case day
    case night
}

protocol ThemesProtocol {
    var classicTheme: ThemeSettings { get }
    var dayTheme: ThemeSettings { get }
    var nightTheme: ThemeSettings { get }
}

struct Themes: ThemesProtocol {

    let classicTheme = ThemeSettings(
        backgroundColor: .white,
        primaryTextColor: .black,
        keyboardAppearance: .light,
        activityIndicatorColor: .darkGray,
        
        navigationBarColor: UIColor(named: "BackgroundNavigationBarColor") ?? .lightGray,
        navigationBarButtonColor: .black,
        photoButtonBackgroundColor: UIColor(named: "CameraButtonColor") ?? .systemBlue,
        textButtonBackgroundColor: UIColor(named: "BackgroundButtonColor") ?? .lightGray,
        buttonTextColor: UIColor(named: "BlueTextColor") ?? .systemBlue
    )
    
    let dayTheme = ThemeSettings(
        backgroundColor: .white,
        primaryTextColor: .black,
        keyboardAppearance: .light,
        activityIndicatorColor: .darkGray,
        
        navigationBarColor: UIColor(named: "BackgroundNavigationBarColor") ?? .lightGray,
        navigationBarButtonColor: .black,
        photoButtonBackgroundColor: UIColor(named: "CameraButtonColor") ?? .systemBlue,
        textButtonBackgroundColor: UIColor(named: "BackgroundButtonColor") ?? .lightGray,
        buttonTextColor: UIColor(named: "BlueTextColor") ?? .systemBlue
    )
    
    let nightTheme = ThemeSettings(
        backgroundColor: .black,
        primaryTextColor: .white,
        keyboardAppearance: .dark,
        activityIndicatorColor: .lightGray,
        
        navigationBarColor: UIColor(named: "IncomingMessageNightThemeColor") ?? .lightGray,
        navigationBarButtonColor: .systemYellow,
        photoButtonBackgroundColor: UIColor(named: "OutcomingMessageNightThemeColor") ?? .systemBlue,
        textButtonBackgroundColor: UIColor(named: "OutcomingMessageNightThemeColor") ?? .lightGray,
        buttonTextColor: .white
    )
}
