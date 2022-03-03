//
//  File.swift
//  ChatApp
//
//  Created by Екатерина on 03.03.2022.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    
    private let contentViewHeight: CGFloat = 96
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in self.subviews {
            let stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarBackground") {
                subview.frame = self.bounds
            } else if stringFromClass.contains("UINavigationBarContentView") {
                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: contentViewHeight)
            }
        }
    }
}
