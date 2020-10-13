//
//  UIViewExtensions.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/6/21.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit

public enum PointerStyle {
    case Highlight
    case Lift
    case SystemDefault
}

public extension UIView {
    func addSubViews(_ views: UIView...) {
        views.forEach { (v) in
            addSubview(v)
        }
    }
    
    func addEffectForPointer(style: PointerStyle = .Highlight) {
        if #available(iOS 13.4, *) {
            self.addInteraction(UIPointerInteraction(delegate: self))
        }
    }
}

extension UIView: UIPointerInteractionDelegate {
    @available(iOS 13.4, *)
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height),
                                              cornerRadius: self.bounds.width / 2)
        let preview = UITargetedPreview(view: self, parameters: parameters)
        return UIPointerStyle(effect: .lift(preview))
    }
}

public extension UIButton {
    func adaptForPointer(style: PointerStyle = .Highlight) {
        if #available(iOS 13.4, *) {
            self.isPointerInteractionEnabled = true

            switch style {
            case .Highlight:
                pointerStyleProvider = { (UIButton, UIPointerEffect, UIPointerShape) -> UIPointerStyle? in
                    let parameters = UIPreviewParameters()
                    parameters.visiblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height),
                                                          cornerRadius: self.bounds.width / 2)
                    let preview = UITargetedPreview(view: self, parameters: parameters)
                    return UIPointerStyle(effect: .highlight(preview))
                }
            break
            case .Lift:
                pointerStyleProvider = { (UIButton, UIPointerEffect, UIPointerShape) -> UIPointerStyle? in
                    let parameters = UIPreviewParameters()
                    parameters.visiblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height),
                                                          cornerRadius: self.bounds.width / 2)
                    let preview = UITargetedPreview(view: self, parameters: parameters)
                    return UIPointerStyle(effect: .lift(preview))
                }
            case .SystemDefault:
                break
            }
        }
    }
}
