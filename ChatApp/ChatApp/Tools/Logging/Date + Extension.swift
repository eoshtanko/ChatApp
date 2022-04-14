//
//  Date + Extension.swift
//  ChatApp
//
//  Created by Екатерина on 07.04.2022.
//

import Foundation

extension Date {
    
    static func fromDateToString(from date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm a"
            return formatter.string(from: date)
        }
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_GB")
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }
}
