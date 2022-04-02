//
//  NetworkManager.swift
//  ChatApp
//
//  Created by Екатерина on 31.03.2022.
//

import Foundation
import Network

// На мой взгляд, разумно было бы предусмотреть в чате отслеживание интернет-соединения.
// Firebase не выдает ошибки при отсутствии связи с сетью, он просто запоминает, скажем, отправленные
// вами сообщения и отсылает их в БД при восстановлении подключения. Кажется, это очень неудачное
// решение для чата.
// Я решила отслеживать соединения и проверять его перед взаимодействием с firebase.
// Однако столкнулась с проблемой: несмотря на верную реализацию монитор не всегда дает верные
// сведения о подключении. Став искать причины проблемы, я столкнулась со следующей информацией в
// интернете: "The simulator cannot accurately transfer network changes to the application. You need to
// test network on real devices due to this limitation."

class NetworkManager {
    private let monitor = NWPathMonitor()
    private(set) var isInternetConnected = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            self.updatePath(path)
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    private func updatePath(_ path: NWPath) {
        if path.status == .satisfied {
            isInternetConnected = true
        } else {
            isInternetConnected = false
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
