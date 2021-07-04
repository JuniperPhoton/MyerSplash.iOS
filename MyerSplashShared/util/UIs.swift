//
//  Uis.swift
//  MyerSplash
//
//  Created by MAC on 2019/11/3.
//  Copyright © 2019 juniper. All rights reserved.
//

import Foundation
import UIKit

public class UIs {
    public static func setLabelColor(_ uiView: UILabel) {
        uiView.textColor = UIColor.getDefaultLabelUIColor()
    }

    public static func setBackgroundColor(_ uiView: UIView) {
        uiView.backgroundColor = UIColor.getDefaultBackgroundUIColor()
    }
}

public extension UILabel {
    func setDefaultLabelColor() {
        self.textColor = UIColor.label
    }
}

public extension UIColor {
    static func getDefaultLabelUIColor() -> UIColor {
        return UIColor.label
    }

    static func getDefaultBackgroundUIColor() -> UIColor {
        return UIColor.systemBackground
    }
}

public func getTopBarHeight() -> CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
        #if targetEnvironment(macCatalyst)
        return 110
        #endif
        return 90
    } else {
        return 60
    }
}

public func getContentTopInsets() -> CGFloat {
    #if targetEnvironment(macCatalyst)
    return getTopBarHeight()
    #else
    return getTopBarHeight() + UIView.topInset
    #endif
}

public extension UIView {
    static var hasTopNotch: Bool {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }

    static var topInset: CGFloat {
        #if targetEnvironment(macCatalyst)
        return 0
        #endif
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
    }
    
    static func makeBlurBackgroundView()-> UIView {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return blurEffectView
    }

    static func getDefaultLabelUIColor() -> UIColor {
        return UIColor.getDefaultLabelUIColor()
    }

    static func getDefaultBackgroundUIColor() -> UIColor {
        return UIColor.getDefaultBackgroundUIColor()
    }

    static func getDefaultDialogBackgroundUIColor() -> UIColor {
        return UIColor { (trainCollection) -> UIColor in
            if trainCollection.userInterfaceStyle == .dark {
                return "1e1e1e".asUIColor()
            } else {
                return "f4f4f4".asUIColor()
            }
        }
    }

    func setDefaultBackgroundColor() {
        self.backgroundColor = UIView.getDefaultBackgroundUIColor()
    }
}
