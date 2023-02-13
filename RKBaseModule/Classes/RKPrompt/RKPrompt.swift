//
//  RKMiddleware.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/7.
//

import Foundation

@objc public protocol RKPromptProtocol : NSObjectProtocol {
    
    @objc func showToast(withText: String?, inView: UIView?)
    
    @objc func showLoading(inView: UIView?)
    
    @objc func hidenLoading(inView: UIView?)
}

public class RKPrompt {
    
    public static let share = RKPrompt()
    
    public var promptDelegate: RKPromptProtocol?
    
    public static func showToast(withText: String?, inView: UIView? = nil) {
        DispatchQueue.main.async {
            share.promptDelegate?.showToast(withText: withText, inView: inView) ?? RKHUD.showToast(withText: withText, inView: inView)
        }
        
    }
    
    public static func showLoading(inView: UIView? = nil) {
        DispatchQueue.main.async {
            share.promptDelegate?.showLoading(inView: inView) ?? RKHUD.show(inView: inView)
        }
    }
    
    public static func hidenLoading(inView: UIView? = nil) {
        DispatchQueue.main.async {
            share.promptDelegate?.hidenLoading(inView: inView) ?? RKHUD.dismiss()
        }
    }
}

