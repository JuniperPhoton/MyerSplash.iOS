//
// Created by MAC on 2020/1/7.
// Copyright (c) 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import MyerSplashShared

class DayNightImageView: UIImageView {
    private var maskColor: UIColor {
        get {
            let maskColor: UIColor!
            if UITraitCollection.current.userInterfaceStyle == .dark {
                maskColor = UIColor.black.withAlphaComponent(0.3)
            } else {
                maskColor = UIColor.clear
            }

            return maskColor
        }
    }
    
    private lazy var foregroundMaskView: UIView! = {
        let maskView = UIView()
        maskView.backgroundColor = maskColor
        return maskView
    }()

    func applyMask() {
        if !AppSettings.isDarkMaskEnabled() {
            if foregroundMaskView.superview != nil {
                foregroundMaskView.removeFromSuperview()
            }
        } else {
            if foregroundMaskView.superview == nil {
                self.addSubview(foregroundMaskView)
                foregroundMaskView.snp.makeConstraints { (maker) in
                    maker.edges.equalToSuperview()
                }
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }

        foregroundMaskView.backgroundColor = maskColor
    }
}
