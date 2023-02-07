//
//  RKMiddleware.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/7.
//

import Foundation

public class RKMiddleware {
    
    public static let share = RKMiddleware()
    
    public var promptDelegate: RKPromptProtocol?
    
    public var contactDelegate: RKContactProtocol?
}


/// 用户信息
@objc public class UserInfo: NSObject {
    /// 用户id
    public let id: String
    /// 用户名称
    public let name: String
    /// 用户头像
    public let avatar: String?
    /// 部门
    public let unitName: String?
    /// 设备类型 1-android  2-ios  3-pc  4-glass  5-web
    public let deviceType: String?
    /// 0-离线 1-在线
    public let status: String?
    
    public init(
        id: String,
        name: String,
        avatar: String? = nil,
        unitName: String? = nil,
        deviceType:String? = nil,
        status:String? = nil
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.unitName = unitName
        self.deviceType = deviceType
        self.status = status
        
        super.init()
    }
}
