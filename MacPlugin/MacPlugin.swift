//
//  MacPlugin.swift
//  MacPlugin
//
//  Created by JuniperPhoton on 2021/6/6.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import AppKit

class MacPlugin: NSObject, Plugin {
    required override init() {
    }

    func setAsWallpaper(path: String) -> Bool {
        do {
            let imgurl = NSURL.fileURL(withPath: path)
            
            print("setAsWallpaper \(imgurl)")
            
            let workspace = NSWorkspace.shared
            try NSScreen.screens.forEach { screen in
                try workspace.setDesktopImageURL(imgurl, for: screen, options: [:])
            }
            return true
        } catch {
            print(error)
            
            return false
        }
    }
}
