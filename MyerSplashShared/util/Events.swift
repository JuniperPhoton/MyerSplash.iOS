//
//  Events.swift
//  MyerSplash
//
//  Created by MAC on 2019/11/5.
//  Copyright © 2019 juniper. All rights reserved.
//

import Foundation
import AppCenterAnalytics

#if !targetEnvironment(macCatalyst)
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
#endif

public class Events {
    public static func initialize() {
        #if !targetEnvironment(macCatalyst)
        MSAppCenter.start(AppKeys.getAppCenterKey(), withServices:[
            MSAnalytics.self,
            MSCrashes.self
        ])
        #endif
    }
    
    public static func trackBeginDownloadEvent() {
        trackMSEvents("Begin download")
    }

    public static func trackImagDetailShown() {
        trackMSEvents("Image detail shown")
    }
    
    public static func trackImagDetailBeginDrag() {
        trackMSEvents("Image detail begin drag")
    }
    
    public static func trackImagDetailTapToDismiss() {
        trackMSEvents("Image detail tap to dismiss")
    }
    
    public static func trackDownloadSuccessEvent() {
        trackMSEvents("Download success")
    }
    
    public static func trackDownloadFailedEvent(_ success: Bool, _ message: String? = nil) {
        trackMSEvents("Download failed", withProperties: ["Success": String(success), "Message": message ?? ""])
    }
    
    public static func trackTabSelected(name: String) {
        trackMSEvents("Tab selected", withProperties: ["name": name])
    }
    
    public static func trackClickSearch() {
        trackMSEvents("Search clicked")
    }
    
    public static func trackClickSearchItem(name: String) {
        trackMSEvents("Search item clicked", withProperties: ["item": name])
    }
    
    public static func trackClickAuthor() {
        trackMSEvents("Author clicked")
    }
    
    public static func trackEdit() {
        trackMSEvents("Edit entered")
    }
    
    public static func trackEditOk() {
        trackMSEvents("Edit composed")
    }

    public static func trackClickMore() {
        trackMSEvents("More entered")
    }
    
    public static func trackRefresh(name: String) {
        trackMSEvents("Refresh", withProperties: ["title": name])
    }
    
    private static func trackMSEvents(_ name: String, withProperties: [String: String]? = nil) {
        #if !targetEnvironment(macCatalyst)
        MSAnalytics.trackEvent(name, withProperties: withProperties)
        #endif
    }
}
