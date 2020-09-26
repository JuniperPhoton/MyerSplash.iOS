//
//  DownloadButton.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/10.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import MyerSplashShared

class DownloadButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)

        setTitle(R.strings.download, for: .normal)
        layer.cornerRadius = Dimensions.SmallRoundCornor.toCGFloat()
        titleLabel!.font = titleLabel!.font.with(traits: .traitBold,
                fontSize: FontSizes.Normal)

        adjustsImageWhenHighlighted = false
        
        let inset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8);
        contentEdgeInsets = inset

        sizeToFit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateStatus(_ item: DownloadItem) {
        switch item.status {
        case DownloadStatus.Downloading.rawValue:
            self.setTitle("\(Int(item.progress * 100))%", for: .normal)
        case DownloadStatus.Success.rawValue:
            #if !targetEnvironment(macCatalyst)
            self.setTitle(R.strings.edit, for: .normal)
            #else
            self.setTitle(R.strings.open_in_folder, for: .normal)
            #endif
        case DownloadStatus.Failed.rawValue:
            self.setTitle(R.strings.retry, for: .normal)
        default:
            self.setTitle(R.strings.download, for: .normal)
        }
    }
}
