//
//  RKAnimatedTransitioning.swift
//  ARExperts
//
//  Created by 刘爽 on 2023/3/6.
//

import UIKit

class RKAnimatedTransitioning: NSObject {
    var duration = 0.25
    var isPresenting: Bool = false
}

extension RKAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let fromView = fromVC?.view
        let toView = toVC?.view
        guard let fromView = fromView, let toView = toView else { return }
        let containerView = transitionContext.containerView
        if isPresenting {
            toView.frame = CGRect(x: 0, y: UI.ScreenHeight, width: UI.ScreenWidth, height: UI.ScreenHeight - 56)
            containerView.addSubview(toView)
            toView.layer.cornerRadius = 10
            let maskPath = UIBezierPath(roundedRect: toView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = toView.bounds
            maskLayer.path = maskPath.cgPath
            toView.layer.mask = maskLayer
        }
        UIView.animate(withDuration: duration, animations: {
            if self.isPresenting {
                containerView.backgroundColor = UIColor(hexInt: 0x777D89, alpha: 0.6)
                toView.frame = CGRect(x: 0, y: 56, width: UI.ScreenWidth, height: UI.ScreenHeight - 56)
            } else {
                fromView.frame = CGRect(x: 0, y: UI.ScreenHeight, width: UI.ScreenWidth, height: UI.ScreenHeight)
                containerView.backgroundColor = .clear
            }
         }) { (finished) in
             if !self.isPresenting {
                 fromView.removeFromSuperview()
             }
             transitionContext.completeTransition(finished)
         }
     }
}
