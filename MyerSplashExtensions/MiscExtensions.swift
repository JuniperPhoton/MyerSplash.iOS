//
//  MiscExtensions.swift
//  MyerSplashExtensions
//
//  Created by JuniperPhoton on 2020/7/12.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    func getTopViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.presentedViewController ?? self.keyWindow?.rootViewController
    }
}

public extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

public extension UIEdgeInsets {
    static func make(unifiedSize: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: CGFloat(unifiedSize), left: CGFloat(unifiedSize), bottom: CGFloat(unifiedSize), right: CGFloat(unifiedSize))
    }
}
