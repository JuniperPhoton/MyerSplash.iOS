//
//  WidgetManager.swift
//  MyerSplashShared
//
//  Created by juniperphoton on 2021/7/15.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import UIKit

#if !targetEnvironment(macCatalyst)
import WidgetKit
#endif

public class WidgetManager {
    private static let TAG = "WidgetManager"
    
    public static let shared: WidgetManager = {
        return WidgetManager()
    }()
    
    private init() {
        // private constructor
    }
    
    public func triggerUpdate() {
        if #available(iOS 14.0, *) {
            #if !targetEnvironment(macCatalyst)
            Log.info(tag: WidgetManager.TAG, "trigger widget update")
            WidgetCenter.shared.reloadTimelines(ofKind: "MyerSplashWidget")
            #endif
        } else {
            // Fallback on earlier versions
        }
    }
}
