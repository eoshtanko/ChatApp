//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Екатерина on 22.02.2022.
//

import UIKit
import Firebase

@main
final class AppDelegate: UIResponder {
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
}

extension AppDelegate: UIApplicationDelegate {
    func application( _ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            FirebaseApp.configure()
            
            window?.rootViewController = UINavigationController(
                rootViewController: ConversationsListViewController()
            )
            window?.makeKeyAndVisible()
            
            return true
        }
}

