//
//  Misc.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/9/26.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import MyerSplashShared
import UIKit
import MaterialComponents.MaterialDialogs

extension UIViewController {
    func presentEdit(item: DownloadItem) {
        // for iOS and iPad OS
        #if !targetEnvironment(macCatalyst)
        let vc = ImageEditorViewController(item: item)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        #else
        guard let fileURL = item.fileURL else {
            return
        }
        
        let path = DownloadManager.instance.createAbsolutePathForImage(fileURL)
        if setAsWallpaper(path: path.path) {
            showToast(R.strings.set_as_wallpaper_success)
        } else {
            showToast(R.strings.set_as_wallpaper_fail)
        }
        #endif
    }
    
    private func setAsWallpaper(path: String) -> Bool {
        MacBundlePlugin.sharedInstance?.setAsWallpaper(path: path) ?? false
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
        
        let image = ImageIO.shared.getCachedImage(unsplashImage.listUrl)
        if image != nil {
            items.append(image!)
        }
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad, let popoverVc = ac.popoverPresentationController {
            popoverVc.sourceView = anchorView
            popoverVc.sourceRect = anchorView.bounds
        }
        
        present(ac, animated: true)
    }
}

extension UIViewController: BottomSheetDelegate {
    func presentBottomSheet(content: SingleChoiceDialog,
                            transitionController: MDCDialogTransitionController,
                            onSelected: @escaping (Int) -> Void) {
        let vc = DialogViewController(dialogContent: content)
        vc.modalPresentationStyle = .custom;
        vc.transitioningDelegate = transitionController;
        vc.makeNormalDialogSize()
        vc.onItemSelected = onSelected
        self.present(vc, animated: true, completion: nil)
    }
}
