//
//  IndicatorTemplate.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/5.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialTabs

class IndicatorTemplate: NSObject, MDCTabBarIndicatorTemplate {
    func indicatorAttributes(
      for context: MDCTabBarIndicatorContext
    ) -> MDCTabBarIndicatorAttributes {
      let attributes = MDCTabBarIndicatorAttributes()
      // Outset frame, round corners, and stroke.
        let indicatorFrame = context.contentFrame.insetBy(dx: 1, dy: 6).offsetBy(dx: 0, dy: 18)
      let path = UIBezierPath(roundedRect: indicatorFrame, cornerRadius: 0)
      attributes.path = path
      return attributes
    }
}
