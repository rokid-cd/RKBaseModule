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

@objc public protocol RKContactProtocol : NSObjectProtocol {
    
    /// 获取联系人列表
    @objc func getContactList() -> [UserInfo]

    /// 获取联系人详情
    @objc func getContact(byId: String) -> UserInfo?
}
