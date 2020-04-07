//
//  UIKitHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 3/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc extension UIApplication {
    @objc public class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let search = base as? UISearchController {
            return search.presentingViewController
        }
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
    @objc public class func topViewController() -> UIViewController? {
        let window = UIApplication.shared.delegate?.window ?? UIApplication.shared.keyWindow
        return topViewController(window?.rootViewController)
    }
}
