//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Екатерина on 22.02.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        LifecycleLogger.log(newState: LifecycleLogger.State.inactive, methodName: #function)
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LifecycleLogger.log(newState: LifecycleLogger.State.inactive, methodName: #function)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        LifecycleLogger.log(newState: LifecycleLogger.State.active, methodName: #function)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        LifecycleLogger.log(newState: LifecycleLogger.State.inactive, methodName: #function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        LifecycleLogger.log(newState: LifecycleLogger.State.background, methodName: #function)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        LifecycleLogger.log(newState: LifecycleLogger.State.inactive, methodName: #function)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        LifecycleLogger.log(newState: LifecycleLogger.State.notRunning, methodName: #function)
    }
}

