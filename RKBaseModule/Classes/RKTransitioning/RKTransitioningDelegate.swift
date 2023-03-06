//
//  RKTransitioningDelegate.swift
//  ARExperts
//
//  Created by 刘爽 on 2023/3/6.
//

import UIKit

class RKTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let at = RKAnimatedTransitioning()
        at.isPresenting = true
        return at
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let at = RKAnimatedTransitioning()
        at.isPresenting = false
        return at
    }
}
