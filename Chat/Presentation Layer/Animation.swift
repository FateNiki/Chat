//
//  Animation.swift
//  Chat
//
//  Created by Алексей Никитин on 23.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class Animations {
    static var emblemCell: CAEmitterCell = {
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "AppIcon")?.cgImage
        cell.scale = 0.6
        cell.scaleRange = 0.3
        cell.lifetime = 5.0
        cell.birthRate = 3
        cell.velocity = -30
        cell.velocityRange = -20
        cell.yAcceleration = CGFloat.random(in: -30...30)
        cell.xAcceleration = CGFloat.random(in: -30...30)
        return cell
    }()
    
    public class func shake(_ view: UIView) {
        let keyTimes: [NSNumber] = [0, 0.25, 0.5, 0.75, 1]
        let keyPositionValues: [NSNumber] = [0, -5, 0, 5, 0]
        
        let positionAnimationX = CAKeyframeAnimation(keyPath: "transform.translation.x")
        positionAnimationX.keyTimes = keyTimes
        positionAnimationX.values = keyPositionValues
       
        let positionAnimationY = CAKeyframeAnimation(keyPath: "transform.translation.y")
        positionAnimationY.keyTimes = keyTimes
        positionAnimationY.values = keyPositionValues

        let rotate = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotate.keyTimes = keyTimes
        rotate.values = [0, CGFloat.pi / 10, 0, -CGFloat.pi / 10, 0].reversed()
        
        let group = CAAnimationGroup()
        group.animations = [
            positionAnimationX,
            rotate,
            positionAnimationY
        ]
        group.duration = 0.3
        group.repeatCount = .infinity
        view.layer.add(group, forKey: "shake")
    }
    
    public class func stopShake(_ view: UIView) {
        view.layer.removeAnimation(forKey: "shake")
        
        guard let currentLayer = view.layer.presentation() else { return }
        
        let positionAnimationX = CABasicAnimation(keyPath: "transform.translation.x")
        positionAnimationX.fromValue = currentLayer.value(forKeyPath: "transform.translation.x")
        positionAnimationX.toValue = 0
        
        let positionAnimationY = CABasicAnimation(keyPath: "transform.translation.y")
        positionAnimationY.fromValue = currentLayer.value(forKeyPath: "transform.translation.y")
        positionAnimationY.toValue = 0
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = currentLayer.value(forKeyPath: "transform.rotation.z")
        rotate.toValue = 0
        
        let group = CAAnimationGroup()
        group.animations = [
            positionAnimationX,
            rotate,
            positionAnimationY
        ]
        group.duration = 0.3
        
        view.layer.add(group, forKey: "stab")
    }
    
    public class func showEmblem(into view: UIView, at position: CGPoint) {
        let emblemLayer = CAEmitterLayer()
        emblemLayer.emitterPosition = position
        emblemLayer.emitterSize = CGSize(width: 10, height: 10)
        emblemLayer.emitterShape = .circle
        emblemLayer.beginTime = CACurrentMediaTime()
        emblemLayer.timeOffset = CFTimeInterval(1)
        emblemLayer.emitterCells = [emblemCell]
        view.layer.addSublayer(emblemLayer)
    }
}
