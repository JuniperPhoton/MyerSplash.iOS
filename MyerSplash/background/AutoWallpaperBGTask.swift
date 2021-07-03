//
//  AutoWallpaperBGTask.swift
//  MyerSplash
//
//  Created by juniperphoton on 2021/7/3.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import BackgroundTasks
import MyerSplashShared
import Alamofire

class AutoWallpaperBGTask {
    private static let TAG = "AutoWallpaperTask"
    static let ID = "com.juniperphoton.myersplash.setwallpapers"
    
    static let shared = {
        AutoWallpaperBGTask()
    }()
    
    private init() {
        // ignored
    }
    
    func scheduleBackgroundTasks() {
        let request = BGAppRefreshTaskRequest(identifier: AutoWallpaperBGTask.ID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 10)
        
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.juniperphoton.myersplash.setwallpapers"]
        Log.warn(tag: AutoWallpaperBGTask.TAG, "about to submit background task")
                
        do {
            try BGTaskScheduler.shared.submit(request)
            Log.warn(tag: AutoWallpaperBGTask.TAG, "submit background task")
        } catch {
            Log.warn(tag: AutoWallpaperBGTask.TAG, "could not schedule app refresh: \(error)")
        }
    }
    
    func handleBackgroundTask(_ task: BGAppRefreshTask) {
        let todayImage = UnsplashImage.createToday()

        Log.warn(tag: AutoWallpaperBGTask.TAG, "handleBackgroundTask \(todayImage)")
        
        var downloadRequest: DownloadRequest? = nil
        
        task.expirationHandler = {
            downloadRequest?.cancel()
        }
        
        showAboutToChangeBanner()
        
        DownloadManager.shared.downloadImage(todayImage) { request in
            downloadRequest = request
        } onSuccess: { fileURL in
            let success = MacBundlePlugin.sharedInstance?.setAsWallpaper(path: fileURL.path) ?? false
            Log.warn(tag: AutoWallpaperBGTask.TAG, "success on downloading today image \(todayImage), set success: \(success)")
            
            // todo use a better way
            task.setTaskCompleted(success: true)
        } onFailure: {
            Log.warn(tag: AutoWallpaperBGTask.TAG, "error on downloading today image \(todayImage)")
            
            task.setTaskCompleted(success: false)
        }
    }
    
    private func showAboutToChangeBanner() {
        let content = UNMutableNotificationContent()
        content.title = "About to change wallpaper"
           
        // Create the trigger as a repeating event.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        let r = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(r) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
}
