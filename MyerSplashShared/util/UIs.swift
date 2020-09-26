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
        if #available(iOS 13.0, *) {
            self.textColor = UIColor.label
        } else {
            self.textColor = UIColor.black
        }
    }
}

public extension UIColor {
    public static func getDefaultLabelUIColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }

    public static func getDefaultBackgroundUIColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
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
    return getTopBarHeight() - 26
    #else
    return getTopBarHeight() + UIView.topInset
    #endif
}

public extension UIView {
    public static var hasTopNotch: Bool {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }

    public static var topInset: CGFloat {
        #if targetEnvironment(macCatalyst)
        return 0
        #endif
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
    }
    
    public static func makeBlurBackgroundView()-> UIView {
        let blurEffect: UIBlurEffect!
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemMaterial)
        } else {
            blurEffect = UIBlurEffect(style: .extraLight)
        }
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return blurEffectView
    }

    public static func getDefaultLabelUIColor() -> UIColor {
        return UIColor.getDefaultLabelUIColor()
    }

    public static func getDefaultBackgroundUIColor() -> UIColor {
        return UIColor.getDefaultBackgroundUIColor()
    }

    public static func getDefaultDialogBackgroundUIColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .dark {
                    return "1e1e1e".asUIColor()
                } else {
                    return "f4f4f4".asUIColor()
                }
            }
        } else {
            return "f4f4f4".asUIColor()
        }
    }

    func setDefaultBackgroundColor() {
        self.backgroundColor = UIView.getDefaultBackgroundUIColor()
    }
}
