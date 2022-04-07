//
//  CoreDataLogger.swift
//  ChatApp
//
//  Created by Екатерина on 07.04.2022.
//

import Foundation

class CoreDataLogger {
    
    // В Info.plist в ключе isLoggingEnable Вы можете указать, будет ли приложение вести логи.
    private static let isLoggingEnable = Bundle.main.object(forInfoDictionaryKey: "isCoreDataLoggingEnable") as? Bool
    private static let formatter = DateFormatter()
    
    public enum SuccessStatus: String {
        case success
        case failure
    }
    
    public static func log(_ msg: String, _ status: SuccessStatus) {
        guard isLoggingEnable ?? false else {
            return
        }
        print(generateMessage(msg, status))
    }
    
    public static func log<T: StringConvertableProtocol>(_ msg: String, _ object: T) {
        guard isLoggingEnable ?? false else {
            return
        }
        var messageToPrint = generateMessage(msg, .success)
        messageToPrint.append(object.toString())
        print(messageToPrint)
    }
    
    public static func log<T>(_ msg: String, _ object: T) {
        if let channel = object as? Channel {
            log(msg, channel)
        } else if let message = object as? Message {
            log(msg, message)
        }
    }
    
    private static func getCurrentTime() -> String {
        let time = NSDate()
        formatter.dateFormat = "hh:mm:ss"
        return formatter.string(from: time as Date) + ": "
    }
    
    private static func generateMessage(_ msg: String, _ status: SuccessStatus) -> String {
        var messageToPrint = getCurrentTime()
        if status == .success {
            messageToPrint.append("🟩")
        } else {
            messageToPrint.append("🟥 Error: ")
        }
        messageToPrint.append(msg)
        return messageToPrint
    }
}
