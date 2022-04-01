//
//  NetworkManager.swift
//  ChatApp
//
//  Created by Екатерина on 31.03.2022.
//

// import Foundation
// import Network
//
// class NetworkManager {
//    private let monitor = NWPathMonitor()
//    private(set) var isInternetConnected = false
//
//    init() {
//        monitor.pathUpdateHandler = { path in
//            if path.status == .satisfied {
//                print(path.status)
//                self.isInternetConnected = true
//            } else if path.status == .unsatisfied {
//                print(path.status)
//                self.isInternetConnected = false
//            }
//        }
//        let queue = DispatchQueue(label: "Monitor")
//        monitor.start(queue: queue)
//    }
// }
