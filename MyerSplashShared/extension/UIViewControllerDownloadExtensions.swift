//
//  UIViewControllerDownloadExtensions.swift
//  MyerSplashShared
//
//  Created by juniperphoton on 2021/7/3.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MDCAlertController

public extension UIViewController {
    func prepareForDownload(_ image: UnsplashImage) {
        Events.trackBeginDownloadEvent()
        
        var reachability: Reachability!
        
        do {
            reachability = try Reachability()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        if reachability.connection != .unavailable {
            print("isReachable")
        } else {
            print("is NOT Reachable")
            self.view.showToast(R.strings.no_network)
            return
        }
        
        if reachability.connection != .wifi {
            print("NOT using wifi")
            if AppSettings.isMeteredEnabled() {
                let alertController = MDCAlertController(
                    title: R.strings.metered_dialog_title,
                    message: R.strings.metered_dialog_message)
                alertController.applyColors()
                let ok = MDCAlertAction(title: R.strings.download) { (action) in
                    DownloadManager.shared.downloadImage(image)
                }
                let cancel = MDCAlertAction(title: R.strings.cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(ok)
                alertController.addAction(cancel)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        DownloadManager.shared.downloadImage(image)
    }
}
