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
        let bgView = containerView.viewWithTag(1001) ?? UIView()
        
        let ScreenWidth  = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ScreenHeight = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        
        if isPresenting {
            bgView.tag = 1001
            bgView.backgroundColor = .clear
            bgView.frame = containerView.bounds
            containerView.addSubview(bgView)

            toView.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight - 56)
            containerView.addSubview(toView)
            
            let maskPath = UIBezierPath(roundedRect: toView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = toView.bounds
            maskLayer.path = maskPath.cgPath
            toView.layer.mask = maskLayer
        }
        UIView.animate(withDuration: duration, animations: {
            if self.isPresenting {
                bgView.backgroundColor = UIColor(hex: 0x777D89).withAlphaComponent(0.6)
                toView.frame = CGRect(x: 0, y: 56, width: ScreenWidth, height: ScreenHeight - 56)
            } else {
                bgView.backgroundColor = .clear
                fromView.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight)
            }
         }) { (finished) in
             if !self.isPresenting {
                 fromView.removeFromSuperview()
             }
             transitionContext.completeTransition(finished)
         }
     }
}
