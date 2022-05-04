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
    var layer: CAEmitterLayer?
}

extension AppDelegate: UIApplicationDelegate {
    func application( _ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        window?.rootViewController = UINavigationController(
            rootViewController: ConversationsListViewController()
        )
        window?.makeKeyAndVisible()
        
        configureGestureRecognizers()
        
        return true
    }
    
    private func configureGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.cancelsTouchesInView = false
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(panAction(_:)))
        longTap.cancelsTouchesInView = false
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        pan.cancelsTouchesInView = false
        
        window?.addGestureRecognizer(tap)
        window?.addGestureRecognizer(longTap)
        window?.addGestureRecognizer(pan)
    }
    
    @objc func tapAction(_ gestureRecognizer: UIGestureRecognizer) {
        if let window = window {
            let layerIcons = BrandParticleAnimation()
                .createLayer(position: gestureRecognizer
                                .location(in: gestureRecognizer.view?.window), size: window.bounds.size)
            
            window.layer.addSublayer(layerIcons)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                layerIcons.removeFromSuperlayer()
            }
        }
    }
    
    @objc func panAction(_ gestureRecognizer: UIGestureRecognizer) {
        if let window = window {
            
            let position = gestureRecognizer.location(in: gestureRecognizer.view)
            
            switch gestureRecognizer.state {
            case .began:
                let layerIcons = BrandParticleAnimation()
                    .createLayer(position: position, size: window.bounds.size)
                window.layer.addSublayer(layerIcons)
                layer = layerIcons
            case .changed:
                layer?.emitterPosition = position
            case .ended, .cancelled:
                layer?.removeFromSuperlayer()
            case .failed, .possible:
                print("failed or possible case")
            default:
                fatalError()
            }
        }
    }
}
