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
}

