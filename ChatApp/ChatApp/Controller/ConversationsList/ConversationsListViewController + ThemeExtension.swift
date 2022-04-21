//
//  ConversationsListViewController + ThemeExtension.swift
//  ChatApp
//
//  Created by Екатерина on 31.03.2022.
//

import Foundation

protocol ThemesPickerDelegate: AnyObject {
    func selectTheme(_ theme: Theme)
}

extension ConversationsListViewController: ThemesPickerDelegate {
    
    func selectTheme(_ theme: Theme) {
        //        if currentTheme != theme {
        //            currentTheme = theme
        //            setCurrentTheme()
        //            memoryManager.saveThemeToMemory()
        //        }
    }
    
    func setCurrentTheme() {
        ConversationTableViewCell.setCurrentTheme(currentTheme)
        profileViewController?.setCurrentTheme(currentTheme)
        switch currentTheme {
        case .classic, .day:
            setDayOrClassicTheme()
        case .night:
            setNightTheme()
        }
    }
}
