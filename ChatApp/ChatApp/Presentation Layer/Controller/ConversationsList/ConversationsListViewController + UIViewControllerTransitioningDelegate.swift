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
        transition.startingPoint = getRightBarButtonLocation()
        transition.circleColor = .systemYellow
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = getRightBarButtonLocation()
        transition.circleColor = .systemYellow
        return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
    
    private func getRightBarButtonLocation() -> CGPoint {
        guard let barButtonView = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView else {
            return CGPoint()
        }
        return barButtonView.convert(barButtonView.center, to: view)
    }
}
