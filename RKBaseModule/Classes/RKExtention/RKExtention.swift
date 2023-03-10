//
//  RKExtention.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/1.
//

import Foundation

extension UIColor {
    convenience init(hex:Int32) {
        self.init(hex: hex, alpha: 1)
    }
    //0x000000
    convenience init(hex:Int32, alpha:CGFloat = 1) {
        let r = CGFloat((hex & 0xff0000) >> 16) / 255
        let g = CGFloat((hex & 0xff00) >> 8) / 255
        let b = CGFloat(hex & 0xff) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

extension String {
    var sizeFormat: String {
        var convertedValue: Double = Double(self) ?? 0
        var multiplyFactor = 0
        let tokens = ["b","k","M","G","T"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format:"%4.2f %@", convertedValue,tokens[multiplyFactor])
    }
    
    var urlEncod: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    var isChinese: Bool {
        let result = unicodeScalars.first { $0 >= "\u{4E00}" && $0 <= "\u{9FA5}" }
        return result != nil
    }
}

extension UIImage {
    public func cicleImage() -> UIImage {
        // 开启图形上下文 false代表透明
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // 获取上下文
        let ctx = UIGraphicsGetCurrentContext()
        // 添加一个圆
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ctx?.addEllipse(in: rect)
        // 裁剪
        ctx?.clip()
        // 将图片画上去
        draw(in: rect)
        // 获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

extension UIApplication {
    class func topViewController() -> UIViewController? {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        let topVC = _topViewController(vc: rootVC)
        return topVC
    }
    
    private class func _topViewController(vc: UIViewController?) -> UIViewController? {
        if let nav = vc as? UINavigationController {
            return _topViewController(vc: nav.topViewController)
        } else if let tab = vc as? UITabBarController {
            return _topViewController(vc: tab.selectedViewController)
        } else if let preVC = vc?.presentedViewController {
            return _topViewController(vc: preVC)
        }
        return vc
    }
}


public extension Bundle {
    class func rkImage(named name: String, _ bundleName: String, _ aclass: AnyClass) -> UIImage? {
        let primaryBundle = Bundle(for: aclass)
        if let image = UIImage(named: name, in: primaryBundle, compatibleWith: nil) {
            return image
            
        } else if let image = UIImage(named: name, in: Bundle.rkBundle(bundleName, aclass), compatibleWith: nil) {
            return image
        }
        return nil
    }
    
    class func rkBundle(_ bundleName: String, _ aclass: AnyClass) -> Bundle {
        let primaryBundle = Bundle(for: aclass)
        if let subBundleUrl = primaryBundle.url(forResource: bundleName, withExtension: "bundle"),
           let subBundle = Bundle(url: subBundleUrl) {
            return subBundle
        }
        return Bundle.main
    }
}
