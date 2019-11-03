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
        uiView.textColor = UIView.getDefaultLabelUIColor()
    }
    
    static func setBackgroundColor(_ uiView: UIView) {
        if #available(iOS 13.0, *) {
            uiView.backgroundColor = UIColor.systemBackground
        } else {
            uiView.backgroundColor = UIColor.black
        }
    }
}

extension UILabel {
    func setDefaultLabelColor() {
        if #available(iOS 13.0, *) {
            self.textColor = UIColor.label
        } else {
            self.textColor = UIColor.white
        }
    }
}

extension UIView {
    static func getDefaultLabelUIColor() -> UIColor {
        if #available(iOS 13.0, *) {
           return UIColor.label
        } else {
           return UIColor.white
        }
    }
    
    static func getDefaultBackgroundUIColor() -> UIColor {
        if #available(iOS 13.0, *) {
           return UIColor.systemBackground
        } else {
           return UIColor.black
        }
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
            return "1e1e1e".asUIColor()
        }
    }
    
    func setDefaultBackgroundColor() {
        self.backgroundColor = UIView.getDefaultBackgroundUIColor()
    }
}
