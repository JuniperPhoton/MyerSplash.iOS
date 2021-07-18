//
//  MacAppPlugin.swift
//  MacPlugin
//
//  Created by juniperphoton on 2021/7/18.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import AppKit

class MacAppPlugin: NSObject, AppPlugin {
    required override init() {
        // empty constructor
    }
    
    func isSupportStatusBarFeature() -> Bool {
        let operatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion
        
        print("operatingSystemVersion is \(operatingSystemVersion)")
        
        return operatingSystemVersion.majorVersion >= 11
    }
}
