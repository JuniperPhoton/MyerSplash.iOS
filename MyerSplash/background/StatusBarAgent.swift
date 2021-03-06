//
//  StatusBarAgent.swift
//  MyerSplash
//
//  Created by juniperphoton on 2021/7/4.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import UIKit
import MyerSplashShared
import Alamofire

class StatusBarAgent {
    public static let shared = {
        StatusBarAgent()
    }()
    
    private static let TAG = "StatusBarAgent"
    
    private init() {
        // ignored
    }
    
    func toggleDock(show: Bool) {
        MacBundlePlugins.sharedApplicationDelegationPlugin?.toggleDockIcon(show: show)
    }
    
    func setup(activated: Bool) {
        guard let statusBarPlugin = MacBundlePlugins.sharedStatusBarPlugin else {
            return
        }
        
        if !activated {
            statusBarPlugin.deactivateStatusItem()
            return
        }
        
        let onSetTodayWallpaper = {
            NotificationManager.shared.showWillSetWallpaper()
            
            let todayImage = UnsplashImage.createToday()
            self.downloadAndSetAsWallpaper(todayImage)
        }
        
        let onSetRandomWallpaper = {
            NotificationManager.shared.showWillSetWallpaper()
            
            let repo = RandomImageRepo()
            repo.filterOption = .Landscape
            repo.contentSafety = .High
            repo.onLoadFinished = { (_ success: Bool, _ page: Int, _ size: Int, _ startIndex: Int) in
                if !success || repo.images.isEmpty {
                   return
                }
                
                let image = repo.images[0]
                self.downloadAndSetAsWallpaper(image)
            }
            repo.loadImage(0)
        }
        
        let converter: (StatusItemConfig) -> String = { item in
            switch item.kind {
            case .Launch:
                return R.strings.status_launch
            case .ToggleDock:
                return R.strings.status_toggle_dock
            case .SetHighlight:
                return R.strings.status_set_today
            case .SetRandom:
                return R.strings.status_set_random
            case .Exit:
                return R.strings.status_exit
            }
        }
        
        let onLaunchApp: () -> Void = {
            MacBundlePlugins.sharedApplicationDelegationPlugin?.launchApp()
        }
        
        let onExitApp: () -> Void = {
            MacBundlePlugins.sharedApplicationDelegationPlugin?.exitApp()
        }
        
        let onToggleDock: (Bool) -> Void = { toggled in
            AppSettings.setSettings(key: Keys.SHOW_DOCK, value: toggled)
        }
        
        statusBarPlugin.register(onToggleDock: onToggleDock,
                                 onSetTodayWallpaper: onSetTodayWallpaper,
                                 onSetRandomWallpaper: onSetRandomWallpaper,
                                 onLaunchApp: onLaunchApp,
                                 onExitApp: onExitApp)
        statusBarPlugin.activateStatusItem(configConverter: converter)
    }
    
    private var previousRequest: DownloadRequest? = nil
    
    private func downloadAndSetAsWallpaper(_ image: UnsplashImage) {
        previousRequest?.cancel()
        
        Log.info(tag: StatusBarAgent.TAG, "downloadAndSetAsWallpaper \(image.downloadUrl ?? "")")
        DownloadManager.shared.downloadImage(image) { request in
            self.previousRequest = request
        } onSuccess: { fileURL in
            let success = MacBundlePlugins.sharedWallpaperPlugin?.setAsWallpaper(path: fileURL.path) ?? false
            if success {
                NotificationManager.shared.showDidSetWallpaper()
            } else {
                NotificationManager.shared.showFailedToSetWallpaper()
            }
        } onFailure: {
            NotificationManager.shared.showFailedToSetWallpaper()
        }
    }
}
