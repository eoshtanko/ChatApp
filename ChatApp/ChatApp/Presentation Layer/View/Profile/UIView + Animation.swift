//
//  UIView + Animation.swift
//  ChatApp
//
//  Created by Екатерина on 01.05.2022.
//

import UIKit

extension UIView {
    
    func animateShaking(xOffset: Int, yOffset: Int, rotationAngleDegrees angle: Double, duration: Double) {
        let animationX = getXShakingAnimation(offset: xOffset)
        let animationY = getYShakingAnimation(offset: yOffset)
        let animationRotate = getRotationShakingAnimation(angle: angle, duration: duration)
        
        let group = CAAnimationGroup()
        group.duration = duration
        group.fillMode = .forwards
        group.repeatCount = .infinity
        group.animations = [animationX, animationY, animationRotate]
        layer.add(group, forKey: "shake")
    }
    
    // На самом деле, view и без этих ухищрений (с использованием одного лишь
    // layer.removeAnimation(forKey: "shake")) вернется в изначальное положение достаточно плавно.
    // Но так красивше :)
    func animateStopShaking() {
        guard let presentationLayer = layer.presentation() else { return }
        
        layer.removeAnimation(forKey: "shake")
        
        let positionAnimation = getReturnToCenterPositionAnimation(presentationLayer: presentationLayer)
        let rotateAnimation = getReturnToZeroAngleAnimation(presentationLayer: presentationLayer)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, rotateAnimation]
        animationGroup.duration = 1
        animationGroup.fillMode = .both
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        layer.add(animationGroup, forKey: "stopShake")
    }
    
    private func getXShakingAnimation(offset: Int) -> CAKeyframeAnimation {
        let animationX = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animationX.values = [0, -offset, 0, offset, 0]
        animationX.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        return animationX
    }
    
    private func getYShakingAnimation(offset: Int) -> CAKeyframeAnimation {
        let animationY = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animationY.values = [0, -offset, 0, offset, 0]
        animationY.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        return animationY
    }
    
    private func getRotationShakingAnimation(angle: Double, duration: Double) -> CAKeyframeAnimation {
        let rotationAngle = degreesToRadians(degrees: angle)
        let animationRotate = CAKeyframeAnimation(keyPath: "transform.rotation")
        animationRotate.values = [0, rotationAngle, 0, -rotationAngle, 0]
        animationRotate.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animationRotate.duration = duration / 2
        animationRotate.repeatCount = 2
        return animationRotate
    }
    
    private func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180.0
    }
    
    private func getReturnToCenterPositionAnimation(presentationLayer: CALayer) -> CAKeyframeAnimation {
        let positionAnimation = CAKeyframeAnimation()
        positionAnimation.keyPath = "position"
        positionAnimation.values = [presentationLayer.position, center]
        positionAnimation.keyTimes = [0, 1]
        return positionAnimation
    }
    
    private func getReturnToZeroAngleAnimation(presentationLayer: CALayer) -> CAKeyframeAnimation {
        let rotateAnimation = CAKeyframeAnimation()
        rotateAnimation.keyPath = "transform.rotation"
        rotateAnimation.values = [presentationLayer.value(forKeyPath: "transform.rotation.z") ?? 0, 0]
        rotateAnimation.keyTimes = [0, 1]
        return rotateAnimation
    }
}
