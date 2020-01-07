//
// Created by MAC on 2020/1/7.
// Copyright (c) 2020 juniper. All rights reserved.
//

import Foundation
import UIKit

class DayNightImageView: UIImageView {
    private var foregroundMaskView: UIView? = nil

    private var maskColor: UIColor {
        get {
            let maskColor: UIColor!
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    maskColor = UIColor.black.withAlphaComponent(0.3)
                } else {
                    maskColor = UIColor.clear
                }
            } else {
                maskColor = UIColor.clear
            }

            return maskColor
        }
    }

    func applyMask() {
        let maskView = UIView()
        maskView.backgroundColor = maskColor
        self.addSubview(maskView)

        maskView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        self.foregroundMaskView = maskView
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
                return
            }
        } else {
            return
        }

        foregroundMaskView?.backgroundColor = maskColor
    }
}