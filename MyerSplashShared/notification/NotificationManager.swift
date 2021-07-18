//
//  NotificationManager.swift
//  MyerSplashShared
//
//  Created by juniperphoton on 2021/7/15.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import UIKit

public class NotificationManager {
    private static let TAG = "NotificationManager"
    
    public static let shared: NotificationManager = {
        return NotificationManager()
    }()
    
    private init() {
        // private constructor
    }
    
    public func requestPermission() {
        #if targetEnvironment(macCatalyst)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { granted, error in
            // don't care
        }
        #endif
    }
    
    public func showWillSetWallpaper() {
        let request = createSetWallpaperRequeset(notificationContent: R.strings.will_set_wallpaper)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let e = error {
                Log.info(tag: NotificationManager.TAG, "error on showing notification \(e)")
            }
        }
    }
    
    public func showDidSetWallpaper() {
        let request = createSetWallpaperRequeset(notificationContent: R.strings.did_set_wallpaper)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let e = error {
                Log.info(tag: NotificationManager.TAG, "error on showing notification \(e)")
            }
        }
    }
    
    public func showFailedToSetWallpaper() {
        let request = createSetWallpaperRequeset(notificationContent: R.strings.fail_set_wallpaper)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let e = error {
                Log.info(tag: NotificationManager.TAG, "error on showing notification \(e)")
            }
        }
    }
    
    private func createSetWallpaperRequeset(notificationContent: String) -> UNNotificationRequest {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let content = UNMutableNotificationContent()
        content.body = notificationContent
           
        // Create the trigger as a repeating event.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        return UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)
    }
}
