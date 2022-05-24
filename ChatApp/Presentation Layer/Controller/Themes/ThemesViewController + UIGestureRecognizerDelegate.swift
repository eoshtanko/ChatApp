//
//  ThemesViewController + UIGestureRecognizerDelegate.swift
//  ChatApp
//
//  Created by Екатерина on 02.05.2022.
//

import UIKit

extension ThemesViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
