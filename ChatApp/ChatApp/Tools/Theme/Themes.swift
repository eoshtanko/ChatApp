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
    var classicTheme: ThemeSettings { mutating get }
    var dayTheme: ThemeSettings { mutating get }
    var nightTheme: ThemeSettings { mutating get }
}

struct Themes: ThemesProtocol {

    lazy private(set) var classicTheme = ThemeSettings(
        backgroundColor: .white,
        primaryTextColor: .black,
        secondaryTextColor: .darkGray,
        keyboardAppearance: .light,
        activityIndicatorColor: .darkGray,
        navigationBarColor: UIColor(named: "BackgroundNavigationBarColor") ?? .lightGray,
        statusBarStyle: .darkContent,
        navigationBarAppearance: lightNavBarAppearance,
        navigationBarButtonColor: .black,
        
        photoButtonBackgroundColor: UIColor(named: "CameraButtonColor") ?? .systemBlue,
        textButtonBackgroundColor: UIColor(named: "BackgroundButtonColor") ?? .lightGray,
        buttonTextColor: UIColor(named: "BlueTextColor") ?? .systemBlue,
        
        themePickerBackgroundColor: UIColor(named: "BackgroundClassicThemeColor") ?? .white,
        
        incomingMessageColor: UIColor(named: "IncomingMessageColor") ?? .lightGray,
        outcomingMessageColor: UIColor(named: "OutcomingMessageColor") ?? .systemYellow,
        
        sendMessageButtonColor: .systemBlue,
        enterMessageViewBackgroundColor: UIColor(named: "BackgroundNavigationBarColor") ?? .lightGray,
        enterMessageTextViewBackgroundColor: .white
    )
    
    lazy private(set) var dayTheme = ThemeSettings(
        backgroundColor: .white,
        primaryTextColor: .black,
        secondaryTextColor: .darkGray,
        keyboardAppearance: .light,
        activityIndicatorColor: .darkGray,
        navigationBarColor: UIColor(named: "BackgroundNavigationBarColor") ?? .lightGray,
        statusBarStyle: .darkContent,
        navigationBarAppearance: lightNavBarAppearance,
        navigationBarButtonColor: .black,
        
        photoButtonBackgroundColor: UIColor(named: "CameraButtonColor") ?? .systemBlue,
        textButtonBackgroundColor: UIColor(named: "BackgroundButtonColor") ?? .lightGray,
        buttonTextColor: UIColor(named: "BlueTextColor") ?? .systemBlue,
        
        themePickerBackgroundColor: UIColor(named: "BackgroundDayThemeColor") ?? .lightGray,
        
        incomingMessageColor: UIColor(named: "IncomingMessageDayThemeColor") ?? .lightGray,
        outcomingMessageColor: UIColor(named: "OutcomingMessageDayThemeColor") ?? .systemYellow,
        
        sendMessageButtonColor: .systemBlue,
        enterMessageViewBackgroundColor: UIColor(named: "BackgroundNavigationBarColor") ?? .lightGray,
        enterMessageTextViewBackgroundColor: .white
    )
    
    lazy private(set) var nightTheme = ThemeSettings(
        backgroundColor: .black,
        primaryTextColor: .white,
        secondaryTextColor: .lightGray,
        keyboardAppearance: .dark,
        activityIndicatorColor: .lightGray,
        navigationBarColor: UIColor(named: "IncomingMessageNightThemeColor") ?? .lightGray,
        statusBarStyle: .lightContent,
        navigationBarAppearance: darkNavBarAppearance,
        navigationBarButtonColor: .systemYellow,
        
        photoButtonBackgroundColor: UIColor(named: "OutcomingMessageNightThemeColor") ?? .systemBlue,
        textButtonBackgroundColor: UIColor(named: "OutcomingMessageNightThemeColor") ?? .lightGray,
        buttonTextColor: .white,
        
        themePickerBackgroundColor: UIColor(named: "BackgroundNightThemeColor") ?? .darkGray,
        
        incomingMessageColor: UIColor(named: "IncomingMessageNightThemeColor") ?? .white,
        outcomingMessageColor: UIColor(named: "OutcomingMessageNightThemeColor") ?? .lightGray,
        
        sendMessageButtonColor: .systemYellow,
        enterMessageViewBackgroundColor: UIColor(named: "IncomingMessageNightThemeColor") ?? .white,
        enterMessageTextViewBackgroundColor: UIColor(named: "OutcomingMessageNightThemeColor") ?? .lightGray
    )
    
    private lazy var lightNavBarAppearance: UINavigationBarAppearance = {
        let lightNavBarAppearance = UINavigationBarAppearance()
        lightNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        lightNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        lightNavBarAppearance.backgroundColor = UIColor(named: "BackgroundNavigationBarColor")
        return lightNavBarAppearance
    }()
    
    private lazy var darkNavBarAppearance: UINavigationBarAppearance = {
        let darkNavBarAppearance = UINavigationBarAppearance()
        darkNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        darkNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        darkNavBarAppearance.backgroundColor = .black
        return darkNavBarAppearance
    }()
}
