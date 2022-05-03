//
//  ConversationsListViewController + UINavigationControllerDelegate.swift
//  ChatApp
//
//  Created by Екатерина on 03.05.2022.
//

import UIKit

extension ConversationsListViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        customTransition.isPushing = (operation == .push)
        return customTransition
    }
}
