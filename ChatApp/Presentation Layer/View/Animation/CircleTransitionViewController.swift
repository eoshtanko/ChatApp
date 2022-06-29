//
//  CircleTransitionViewController.swift
//  ChatApp
//
//  Created by Екатерина on 04.05.2022.
//
//

import UIKit

class CircleTransitionViewController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var circleColor: UIColor = .white
    var transitionMode: CircleTransitionMode = .present
    var startingPoint = CGPoint.zero {
        didSet {
            circle.center = startingPoint
        }
    }
    
    private(set) var circle = UIView()
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Const.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        
        guard let fromVC = fromVC, let toVC = toVC else {
            return
        }
        
        if transitionMode == .present {
            animatePresent(using: transitionContext, fromVC: fromVC, toVC: toVC)
        } else {
            animateDismiss(using: transitionContext, fromVC: fromVC, toVC: toVC)
        }
    }
    
    private func animatePresent(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController) {
        
        fromVC.beginAppearanceTransition(false, animated: true)
        if toVC.modalPresentationStyle == .custom {
            toVC.beginAppearanceTransition(true, animated: true)
        }
        
        guard let presentedControllerView = transitionContext.view(forKey: .to) else {
            return
        }
        
        let originalCenter = presentedControllerView.center
        
        // Создаем и настраиваем "круг" анимации
        circle = createCircle(originalCenter: originalCenter,
                              originalSize: presentedControllerView.frame.size)
        transitionContext.containerView.addSubview(circle)
        
        // Настраиваем контроллер, на который переходим
        presentedControllerView.center = startingPoint
        presentedControllerView.transform = CGAffineTransform(scaleX: Const.scalingValue,
                                                              y: Const.scalingValue)
        presentedControllerView.alpha = 0
        
        transitionContext.containerView.addSubview(presentedControllerView)
        
        // Анимируем открытие
        animatePresent(using: transitionContext, fromVC: fromVC, toVC: toVC, presentedControllerView: presentedControllerView, center: originalCenter)
    }
    
    // Создание круга анимации
    private func createCircle(originalCenter: CGPoint, originalSize: CGSize) -> UIView {
        circle = UIView()
        configureCircle(circle: circle,
                        originalCenter: originalCenter,
                        originalSize: originalSize)
        circle.transform = CGAffineTransform(scaleX: Const.scalingValue,
                                             y: Const.scalingValue)
        return circle
    }
    
    // Сама анимация открытия
    private func animatePresent(using transitionContext: UIViewControllerContextTransitioning,
                                fromVC: UIViewController, toVC: UIViewController,
                                presentedControllerView: UIView, center: CGPoint) {
        UIView.animate(withDuration: Const.transitionDuration, animations: {
            self.circle.transform = CGAffineTransform.identity
            presentedControllerView.transform = CGAffineTransform.identity
            presentedControllerView.alpha = 1
            presentedControllerView.center = center
        }, completion: { (_) in
            transitionContext.completeTransition(true)
            self.circle.isHidden = true
            if toVC.modalPresentationStyle == .custom {
                toVC.endAppearanceTransition()
            }
            fromVC.endAppearanceTransition()
        })
    }
    
    private func animateDismiss(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController) {
        
        if fromVC.modalPresentationStyle == .custom {
            fromVC.beginAppearanceTransition(false, animated: true)
        }
        toVC.beginAppearanceTransition(true, animated: true)
        
        guard let returningControllerView = transitionContext.view(forKey: .from) else {
            return
        }
        
        let originalCenter = returningControllerView.center
        
        // Настраиваем "круг" анимации
        configureCircle(circle: circle,
                        originalCenter: originalCenter,
                        originalSize: returningControllerView.frame.size)
        circle.isHidden = false
        
        // Анимируем закрытие
        animateDismiss(using: transitionContext, fromVC: fromVC, toVC: toVC, returningControllerView: returningControllerView, center: originalCenter)
    }
    
    // Сама анимация закрытия
    private func animateDismiss(using transitionContext: UIViewControllerContextTransitioning,
                                fromVC: UIViewController, toVC: UIViewController,
                                returningControllerView: UIView, center: CGPoint) {
        
        UIView.animate(withDuration: Const.transitionDuration, animations: {
            self.circle.transform = CGAffineTransform(scaleX: Const.scalingValue,
                                                      y: Const.scalingValue)
            returningControllerView.transform = CGAffineTransform(scaleX: Const.scalingValue,
                                                                  y: Const.scalingValue)
            returningControllerView.center = self.startingPoint
            returningControllerView.alpha = 0
        }, completion: { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            if !transitionContext.transitionWasCancelled {
                returningControllerView.center = center
                returningControllerView.removeFromSuperview()
                self.circle.removeFromSuperview()
                
                if fromVC.modalPresentationStyle == .custom {
                    fromVC.endAppearanceTransition()
                }
                toVC.endAppearanceTransition()
            }
        })
    }
    
    // Универсальная для открытия и закрытия настройка "круга" анимации
    private func configureCircle(circle: UIView, originalCenter: CGPoint, originalSize: CGSize) {
        circle.frame = getFrameForCircle(originalCenter, size: originalSize, start: startingPoint)
        circle.layer.cornerRadius = circle.frame.size.height / 2
        circle.backgroundColor = circleColor
        circle.center = startingPoint
    }
    
    private func getFrameForCircle(_ originalCenter: CGPoint, size originalSize: CGSize, start: CGPoint) -> CGRect {
        let lengthX = max(start.x, originalSize.width - start.x)
        let lengthY = max(start.y, originalSize.height - start.y)
        let offset = sqrt(lengthX * lengthX + lengthY * lengthY) * 2
        let size = CGSize(width: offset, height: offset)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
    
    enum CircleTransitionMode {
        case present, dismiss
    }
    
    private enum Const {
        static let transitionDuration = 0.5
        static let scalingValue = 0.001
    }
}
