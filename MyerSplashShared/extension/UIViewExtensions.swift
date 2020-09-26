//
//  UIViewExtensions.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/6/21.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    func addSubViews(_ views: UIView...) {
        views.forEach { (v) in
            addSubview(v)
        }
    }
}
