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
    
    func presentShare(_ unsplashImage: UnsplashImage) {
        let url = unsplashImage.downloadUrl!
        let image = ImageIO.getCachedImage(unsplashImage.listUrl)
        
        let content: String!
        if unsplashImage.userName != nil && unsplashImage.isUnsplash {
            content = String(format: R.strings.share_content, arguments: [unsplashImage.userName!])
        } else {
            content = R.strings.share_content_highlight
        }

        let items = [content, URL(string: url)!, image] as [Any?]
        let ac = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        present(ac, animated: true)
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
