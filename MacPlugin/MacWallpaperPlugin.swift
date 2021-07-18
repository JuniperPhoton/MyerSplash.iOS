//
//  MacWallpaperPlugin.swift
//  MacPlugin
//
//  Created by juniperphoton on 2021/7/15.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import AppKit

class MacWallpaperPlugin: NSObject, WallpaperPlugin {
    required override init() {
    }
    
    // MARK: Set as wallpaper
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
