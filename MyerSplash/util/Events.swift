//
//  Events.swift
//  MyerSplash
//
//  Created by MAC on 2019/11/5.
//  Copyright © 2019 juniper. All rights reserved.
//

import Foundation
import AppCenterAnalytics

class Events {
    static func trackBeginDownloadEvent() {
        MSAnalytics.trackEvent("Begin download")
    }

    static func trackImagDetailShown() {
        MSAnalytics.trackEvent("Image detail shown")
    }
    
    static func trackImagDetailBeginDrag() {
        MSAnalytics.trackEvent("Image detail begin drag")
    }
    
    static func trackImagDetailTapToDismiss() {
        MSAnalytics.trackEvent("Image detail tap to dismiss")
    }
    
    static func trackDownloadSuccessEvent() {
        MSAnalytics.trackEvent("Download success")
    }
    
    static func trackDownloadFailedEvent(_ success: Bool, _ message: String? = nil) {
        MSAnalytics.trackEvent("Download failed", withProperties: ["Success": String(success), "Message": message ?? ""])
    }
    
    static func trackTabSelected(name: String) {
        MSAnalytics.trackEvent("Tab selected", withProperties: ["name": name])
    }
    
    static func trackClickSearch() {
        MSAnalytics.trackEvent("Search clicked")
    }
    
    static func trackClickSearchItem(name: String) {
        MSAnalytics.trackEvent("Search item clicked", withProperties: ["item": name])
    }
    
    static func trackClickAuthor() {
        MSAnalytics.trackEvent("Author clicked")
    }
    
    static func trackEdit() {
        MSAnalytics.trackEvent("Edit entered")
    }
    
    static func trackEditOk() {
        MSAnalytics.trackEvent("Edit composed")
    }

    static func trackClickMore() {
        MSAnalytics.trackEvent("More entered")
    }
    
    static func trackRefresh(name: String) {
        MSAnalytics.trackEvent("Refresh", withProperties: ["title": name])
    }
}
