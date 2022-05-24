//
//  CircleInteractiveTransition.swift
//  ChatApp
//
//  Created by Екатерина on 04.05.2022.
//

import UIKit

// Позволяет красиво сворачивать экран при помощи Pan-а
class CircleInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    private var interactionShouldFinish = false
    private var controller: UIViewController?
    
    func attach(to viewController: UIViewController) {
        controller = viewController
        controller?.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CircleInteractiveTransition.handlePan(gesture:))))
        wantsInteractiveStart = false
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard let controller = controller, let view = controller.view else { return }
        
        let translation = gesture.translation(in: controller.view.superview)
        let movement = max(Float(translation.y / view.bounds.height), 0.0)
        let progress = CGFloat(min(movement, 1.0))
        
        switch gesture.state {
        case .began:
            controller.dismiss(animated: true, completion: nil)
        case .changed:
            interactionShouldFinish = progress > Const.interactionThreshold
            update(progress)
        case .cancelled:
            interactionShouldFinish = false
            fallthrough
        case .ended:
            interactionShouldFinish ? finish() : cancel()
        default:
            break
        }
    }
    
    private enum Const {
        static let interactionThreshold: CGFloat = 0.3
    }
}
