//
//  Uis.swift
//  MyerSplash
//
//  Created by MAC on 2019/11/3.
//  Copyright © 2019 juniper. All rights reserved.
//

import Foundation
import UIKit

class UIs {
    static func setLabelColor(_ uiView: UILabel) {
        uiView.textColor = UIColor.getDefaultLabelUIColor()
    }

    static func setBackgroundColor(_ uiView: UIView) {
        uiView.backgroundColor = UIColor.getDefaultBackgroundUIColor()
    }
}

extension UILabel {
    func setDefaultLabelColor() {
        if #available(iOS 13.0, *) {
            self.textColor = UIColor.label
        } else {
            self.textColor = UIColor.black
        }
    }
}

extension UIColor {
    static func getDefaultLabelUIColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }

    static func getDefaultBackgroundUIColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }
}

func getTopBarHeight() -> CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
        #if targetEnvironment(macCatalyst)
        return 110
        #endif
        return 90
    } else {
        return 60
    }
}

func getContentTopInsets() -> CGFloat {
    #if targetEnvironment(macCatalyst)
    return getTopBarHeight() - 26
    #else
    return getTopBarHeight() + UIView.topInset
    #endif
}

extension UIView {
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

    static func getDefaultLabelUIColor() -> UIColor {
        return UIColor.getDefaultLabelUIColor()
    }

    static func getDefaultBackgroundUIColor() -> UIColor {
        return UIColor.getDefaultBackgroundUIColor()
    }

    static func getDefaultDialogBackgroundUIColor() -> UIColor {
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
