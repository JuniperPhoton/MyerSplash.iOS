//
//  DownloadManager.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/8.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import MaterialComponents.MDCAlertController
import Alamofire

class DownloadManager {
    static func prepareToDownload(vc: UIViewController, image: UnsplashImage, success: @escaping (String)->Void) {
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
            vc.view.showToast("Network unavailable :(")
            return
        }

        if reachability.connection != .wifi {
            print("NOT using wifi")
            if AppSettings.isMeteredEnabled() {
                let alertController = MDCAlertController(title: "Alert", message: "You are using meterred network, continue to download?")
                let ok = MDCAlertAction(title: "OK") { (action) in
                    self.doDownload(vc, image, success: success)
                }
                let cancel = MDCAlertAction(title: "CANCEL") { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(ok)
                alertController.addAction(cancel)

                vc.present(alertController, animated: true, completion: nil)
                return
            }
        }

        doDownload(vc, image, success: success)
    }
    
    private static func doDownload(_ vc: UIViewController, _ unsplashImage: UnsplashImage, success: @escaping (String)->Void) {
        print("downloading: \(unsplashImage.downloadUrl ?? "")")

        vc.view.showToast("Downloading in background...")

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL
                    = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(unsplashImage.fileName)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        Events.trackBeginDownloadEvent()

        Alamofire.download(unsplashImage.downloadUrl!, to: destination).response { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            if response.error == nil, let imagePath = response.destinationURL?.path {
                print("image downloaded!")
                Events.trackDownloadEvent(true)
                success(imagePath)
            } else {
                Events.trackDownloadEvent(false, response.error?.localizedDescription)
                print("error while download image: %@", response.error ?? "")
            }
        }
    }
    
    static func showSavedToastOnVC(_ vc: UIViewController, success: Bool) {
        if success {
            vc.view.showToast("Saved to your album :D")
        } else {
            vc.view.showToast("Failed to download :(")
        }
    }
}
