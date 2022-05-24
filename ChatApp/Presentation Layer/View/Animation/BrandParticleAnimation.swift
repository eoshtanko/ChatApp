//
//  BrandParticleAnimation.swift
//  ChatApp
//
//  Created by Екатерина on 02.05.2022.
//

import UIKit

class BrandParticleAnimation {
    
    lazy var tinkoffCell: CAEmitterCell = {
        var cell = CAEmitterCell()
        cell.contents = UIImage(named: "emblemOfTinkoff")?.cgImage
        cell.scale = 0.05
        cell.scaleRange = 0.05
        cell.emissionRange = .pi
        cell.lifetime = 0.4
        cell.birthRate = 5
        cell.velocity = 60
        cell.velocityRange = 20
        cell.xAcceleration = 20
        cell.yAcceleration = 20
        cell.spin = -0.5
        cell.spinRange = 1.0
        
        return cell
    }()
    
    func createLayer(position: CGPoint, size: CGSize) -> CAEmitterLayer {
        let flakeLayer = CAEmitterLayer()
        flakeLayer.emitterPosition = position
        flakeLayer.emitterSize = size
        flakeLayer.emitterShape = .point
        flakeLayer.beginTime = CACurrentMediaTime()
        flakeLayer.timeOffset = CFTimeInterval(Int.random(in: 0...6) + 5)
        flakeLayer.emitterCells = [tinkoffCell]
        return flakeLayer
    }
}
