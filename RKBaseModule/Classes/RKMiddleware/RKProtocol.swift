//
//  RKProtocol.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/7.
//

import Foundation

@objc public protocol RKPromptProtocol : NSObjectProtocol {
    
    @objc func showToast(withText: String, inView: UIView?)
    
    @objc func showLoading(inView: UIView?)
    
    @objc func hidenLoading(inView: UIView?)
}
