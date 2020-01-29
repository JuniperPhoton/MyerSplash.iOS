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
    
    func presentShare(_ unsplashImage: UnsplashImage, _ anchorView: UIView) {
        let url = unsplashImage.downloadUrl!
        
        let content: String!
        if unsplashImage.userName != nil && unsplashImage.isUnsplash {
            content = String(format: R.strings.share_content, arguments: [unsplashImage.userName!])
        } else {
            content = R.strings.share_content_highlight
        }

        var items = [content!, URL(string: url)!] as [Any]
        
        let image = ImageIO.getCachedImage(unsplashImage.listUrl)
        if image != nil {
            items.append(image!)
        }
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.modalPresentationStyle = .fullScreen
        present(ac, animated: true)

        if UIDevice.current.userInterfaceIdiom == .pad {
            ac.popoverPresentationController?.sourceView = anchorView
            ac.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        }
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
