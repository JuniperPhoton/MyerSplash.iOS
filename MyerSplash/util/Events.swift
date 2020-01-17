//
//  Events.swift
//  MyerSplash
//
//  Created by MAC on 2019/11/5.
//  Copyright © 2019 juniper. All rights reserved.
//

import Foundation
import AppCenterAnalytics
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class Events {
    static func initialize() {
        MSAppCenter.start(AppKeys.getAppCenterKey(), withServices:[
            MSAnalytics.self,
            MSCrashes.self
        ])
    }
    
    static func trackBeginDownloadEvent() {
        trackMSEvents("Begin download")
    }

    static func trackImagDetailShown() {
        trackMSEvents("Image detail shown")
    }
    
    static func trackImagDetailBeginDrag() {
        trackMSEvents("Image detail begin drag")
    }
    
    static func trackImagDetailTapToDismiss() {
        trackMSEvents("Image detail tap to dismiss")
    }
    
    static func trackDownloadSuccessEvent() {
        trackMSEvents("Download success")
    }
    
    static func trackDownloadFailedEvent(_ success: Bool, _ message: String? = nil) {
        trackMSEvents("Download failed", withProperties: ["Success": String(success), "Message": message ?? ""])
    }
    
    static func trackTabSelected(name: String) {
        trackMSEvents("Tab selected", withProperties: ["name": name])
    }
    
    static func trackClickSearch() {
        trackMSEvents("Search clicked")
    }
    
    static func trackClickSearchItem(name: String) {
        trackMSEvents("Search item clicked", withProperties: ["item": name])
    }
    
    static func trackClickAuthor() {
        trackMSEvents("Author clicked")
    }
    
    static func trackEdit() {
        trackMSEvents("Edit entered")
    }
    
    static func trackEditOk() {
        trackMSEvents("Edit composed")
    }

    static func trackClickMore() {
        trackMSEvents("More entered")
    }
    
    static func trackRefresh(name: String) {
        trackMSEvents("Refresh", withProperties: ["title": name])
    }
    
    private static func trackMSEvents(_ name: String, withProperties: [String: String]? = nil){
        MSAnalytics.trackEvent(name, withProperties: withProperties)
    }
}
