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
    
    static func trackDownloadEvent(_ success: Bool, _ message: String? = nil) {
        MSAnalytics.trackEvent("Begin download", withProperties: ["Success" : String(success), "Message" : message ])
    }
    
    static func trackRefresh() {
        MSAnalytics.trackEvent("Refresh")
    }
}
