//
//  MemoryManager.swift
//  ChatApp
//
//  Created by Екатерина on 17.03.2022.
//

import Foundation

// С прошлой ДЗ
class MemoryManager {

    private let themeKey = "theme"

    func getThemeFromMemory()->Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: themeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .classic
        }
    }

    func saveThemeToMemory(_ theme: Theme){
        UserDefaults.standard.setValue(theme.rawValue, forKey: themeKey)
        UserDefaults.standard.synchronize()
    }
}
