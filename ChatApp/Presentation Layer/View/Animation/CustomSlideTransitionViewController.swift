//
//  CustomSlideTransitionViewController.swift
//  ChatApp
//
//  Created by Екатерина on 03.05.2022.
//

import UIKit

class CustomSlideTransitionViewController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var transitionMode: UINavigationController.Operation = .push
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Const.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        guard let fromVC = fromVC, let toVC = toVC else {
            return
        }
        
        if transitionMode == .push {
            animatePush(using: transitionContext, fromVC: fromVC, toVC: toVC)
        } else {
            animatePop(using: transitionContext, fromVC: fromVC, toVC: toVC)
        }
    }
    
    func animatePush(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController) {
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalFrame.offsetBy(dx: finalFrame.width, dy: Const.offsetValueForY)
        transitionContext.containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        
        UIView.animate( withDuration: transitionDuration(using: transitionContext),
                        animations: { toVC.view.frame = finalFrame },
                        completion: { _ in transitionContext.completeTransition(true) })
    }
    
    func animatePop(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController) {
        
        let initialFrame = transitionContext.initialFrame(for: fromVC)
        let offsetRect = initialFrame.offsetBy(dx: initialFrame.width, dy: Const.offsetValueForY)
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        UIView.animate( withDuration: transitionDuration(using: transitionContext),
                        animations: { fromVC.view.frame = offsetRect },
                        completion: { _ in transitionContext.completeTransition(true) })
    }
    
    private enum Const {
        static let transitionDuration = 0.35
        static let offsetValueForY: CGFloat = 55
    }
}
