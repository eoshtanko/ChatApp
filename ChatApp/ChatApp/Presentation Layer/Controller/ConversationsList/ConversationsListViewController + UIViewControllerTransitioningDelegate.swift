//
//  ConversationsListViewController + UIViewControllerTransitioningDelegate.swift
//  ChatApp
//
//  Created by Екатерина on 04.05.2022.
//

import UIKit

extension ConversationsListViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: view.frame.maxX - Const.circleTransitionOffset,
                                           y: Const.circleTransitionOffset)
        transition.circleColor = .systemYellow
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint(x: view.frame.maxX - Const.circleTransitionOffset,
                                           y: Const.circleTransitionOffset)
        transition.circleColor = .systemYellow
        return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}
