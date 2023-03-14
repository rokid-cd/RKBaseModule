//
//  RKDeviceOrientation.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/3/14.
//

import Foundation
@objcMembers
public class RKLandOrientation: NSObject {
    public static var shared = RKLandOrientation()
    
    public var orientation: UIInterfaceOrientationMask = .portrait
}

public extension UIDevice {
    
    @objc static func switchOrientation(auto: Bool = false, orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation) {
        
        if auto {
            // 自动切换方向
            RKLandOrientation.shared.orientation = .allButUpsideDown
        } else if orientation == .portrait {
            // 强制竖屏
            RKLandOrientation.shared.orientation = .portrait
        } else {
            // 强制横屏
            RKLandOrientation.shared.orientation = .landscape
        }
        
        if orientation == .portrait &&
            UIApplication.shared.statusBarOrientation != .portrait {
            if #available(iOS 16.0, *) {
                UIApplication.topViewController()?.setNeedsUpdateOfSupportedInterfaceOrientations()
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait), errorHandler: { error in
                    print("旋转为竖屏错误：\(error)")
                })
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
            
        } else if orientation != .portrait && UIApplication.shared.statusBarOrientation != .landscapeLeft && UIApplication.shared.statusBarOrientation != .landscapeRight {
            if #available(iOS 16.0, *) {
                UIApplication.topViewController()?.setNeedsUpdateOfSupportedInterfaceOrientations()
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight), errorHandler: { error in
                    print("旋转为横屏错误：\(error)")
                })
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
