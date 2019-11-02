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
    
    func setDefaultBackgroundColor() {
        if #available(iOS 13.0, *) {
            self.backgroundColor = UIColor.systemBackground
        } else {
            self.backgroundColor = UIColor.black
        }
    }
}
