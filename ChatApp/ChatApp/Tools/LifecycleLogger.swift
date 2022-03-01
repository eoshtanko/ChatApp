//
//  LifecycleLogger.swift
//  ChatApp
//
//  Created by Екатерина on 22.02.2022.
//

import Foundation

class LifecycleLogger {
    
    // В Info.plist в ключе isLoggingEnable Вы можете указать, будет ли приложение вести логи.
    private static let isLoggingEnable = Bundle.main.object(forInfoDictionaryKey: "isLoggingEnable") as? Bool
    private static let formatter = DateFormatter()
    
    // Последнее состояние, в котором пребывало приложение.
    private static var lastState = State.notRunning
    
    // Так как enum UIApplication.State содержит всего 3 значения (active, inactive и background),
    // я решила для полного анализа создать свое перечисление:
    public enum State: String {
        case notRunning
        case inactive
        case active
        case background
        case suspended // Не используется. Прописано для порядка.
    }
    
    public enum Time: String {
        case past = "moved"
        case future = "will move"
    }
    
    public static func log(newState: State? = nil, time: Time? = nil, methodName: String) {
        // Приложение не упадет, если удалить isLoggingEnable из Info.plist.
        guard isLoggingEnable ?? false else {
            return
        }
        printCurrentTime()
        printLoggedinfo(newState, time, methodName)
    }
    
    // Подумала, что информация о времени - дополнительный плюс :)
    private static func printCurrentTime() {
        let time = NSDate()
        formatter.dateFormat = "hh:mm:ss"
        print(formatter.string(from: time as Date), terminator: ": ")
    }
    
    private static func printLoggedinfo(_ newState: State?, _ time: Time?, _ methodName: String) {
        if (methodName.starts(with: "application")) {
            printApplicationStateInfo(newState, time, methodName)
        } else {
            printControllerStateInfo(methodName)
        }
    }
    
    private static func printApplicationStateInfo(_ newState: State?, _ time: Time?, _ methodName: String) {
        guard let newState = newState, let time = time else {
            return
        }
        if (lastState != newState) {
            print("📕 Application \(time.rawValue) from \(lastState) to \(newState): \(methodName).")
            lastState = newState
        } else {
            print("📕 Application didn't change state. State is still \(lastState): \(methodName).")
        }
    }
    
    private static func printControllerStateInfo(_ methodName: String) {
        print("📘 UIViewController lifecycle stage: \(methodName).")
    }
}
