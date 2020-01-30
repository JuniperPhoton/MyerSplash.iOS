//
//  UICollectionViewCellExtensions.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/30.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    func invalidateLayer() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: Dimensions.SHADOW_OFFSET_Y)
        layer.shadowRadius = Dimensions.SHADOW_RADIUS.toCGFloat()
        layer.shadowOpacity = Dimensions.SHADOW_OPACITY
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
    }
}
