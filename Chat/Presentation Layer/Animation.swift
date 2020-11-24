//
//  Animation.swift
//  Chat
//
//  Created by Алексей Никитин on 23.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit

class Animations {
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
}

class EmblemAnimations {
    private static var emblemCell: CAEmitterCell = {
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "emblem")?.cgImage
        cell.scale = 0.1
        cell.lifetime = 3.0
        cell.birthRate = 1
        cell.velocity = CGFloat.random(in: -30...30)
        cell.velocityRange = CGFloat.random(in: -30...30)
        cell.yAcceleration = CGFloat.random(in: -30...30)
        cell.xAcceleration = CGFloat.random(in: -30...30)
        return cell
    }()
    
    private static var emblemLayer: CAEmitterLayer = {
        let emblemLayer = CAEmitterLayer()
        emblemLayer.emitterSize = CGSize(width: 10, height: 10)
        emblemLayer.emitterShape = .circle
        emblemLayer.beginTime = CACurrentMediaTime()
        emblemLayer.timeOffset = CFTimeInterval(1)
        emblemLayer.emitterCells = [emblemCell]
        return emblemLayer
    }()
    
    static func addToLayer(_ layer: CALayer) {
        layer.addSublayer(emblemLayer)
    }
    
    static func remove() {
        emblemLayer.removeFromSuperlayer()
    }
    
    static func moveToPosition(_ position: CGPoint) {
        emblemLayer.emitterPosition = position
    }

}

extension UIView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let window = self.window else { return }
        EmblemAnimations.moveToPosition(touch.location(in: window))
        EmblemAnimations.addToLayer(window.layer)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first, let window = self.window else { return }
        EmblemAnimations.moveToPosition(touch.location(in: window))
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        EmblemAnimations.remove()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        EmblemAnimations.remove()
    }
}

class FadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let dismissing: Bool
    
    init(dismissing: Bool) {
        self.dismissing = dismissing
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if dismissing {
            dismiss(using: transitionContext)
        } else {
            present(using: transitionContext)
        }
    }
    
    private func dismiss(using context: UIViewControllerContextTransitioning) {
        guard let fromVC = context.viewController(forKey: .from) else { return }
        
        let containerView = context.containerView
        
        containerView.addSubview(fromVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: context),
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                            fromVC.view.alpha = 0
                       }, completion: { _ in
                            context.completeTransition(true)
                       })
    }
    
    private func present(using context: UIViewControllerContextTransitioning) {
        guard let toVC = context.viewController(forKey: .to),
              let fromVC = context.viewController(forKey: .from) else { return }
        
        let containerView = context.containerView
        
        toVC.view.alpha = 0
        toVC.view.frame = fromVC.view.frame
        containerView.addSubview(toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: context),
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                            toVC.view.alpha = 1
                       }, completion: { _ in
                        context.completeTransition(true)
                       })
    }
}
