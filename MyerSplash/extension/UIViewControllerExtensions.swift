//
//  UIViewControllerExtensions.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/10.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

extension UIViewController {
    func presentEdit(item: DownloadItem) {
        #if !targetEnvironment(macCatalyst)
        let vc = ImageEditorViewController(item: item)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        #else
        let path = DownloadManager.instance.createSavingDir()
        UIApplication.shared.open(path)
        #endif
    }
}

extension MDCAlertController {
    func applyColors() {
        backgroundColor = .getDefaultBackgroundUIColor()
        titleColor = .getDefaultLabelUIColor()
        messageColor = .getDefaultLabelUIColor()
        buttonTitleColor = .getDefaultLabelUIColor()
    }
}
