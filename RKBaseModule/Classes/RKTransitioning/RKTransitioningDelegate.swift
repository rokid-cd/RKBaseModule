//
//  RKTransitioningDelegate.swift
//  ARExperts
//
//  Created by 刘爽 on 2023/3/6.
//

import UIKit

public class RKTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let at = RKAnimatedTransitioning()
        at.isPresenting = true
        return at
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let at = RKAnimatedTransitioning()
        at.isPresenting = false
        return at
    }
}
