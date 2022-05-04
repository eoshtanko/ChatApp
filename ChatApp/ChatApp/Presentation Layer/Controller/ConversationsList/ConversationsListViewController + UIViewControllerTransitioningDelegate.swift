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
        circleTransition.transitionMode = .present
        circleTransition.startingPoint = getRightBarButtonLocation()
        circleTransition.circleColor = .systemYellow
        return circleTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circleTransition.transitionMode = .dismiss
        circleTransition.startingPoint = getRightBarButtonLocation()
        circleTransition.circleColor = .systemYellow
        return circleTransition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveCircleTransition
    }
    
    private func getRightBarButtonLocation() -> CGPoint {
        guard let barButtonView = self.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView else {
            return CGPoint()
        }
        return barButtonView.convert(barButtonView.center, to: view)
    }
}
