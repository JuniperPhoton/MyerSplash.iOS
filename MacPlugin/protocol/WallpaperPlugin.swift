//
//  WallpaperPlugin.swift
//  MacPlugin
//
//  Created by juniperphoton on 2021/7/15.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import AppKit

@objc(WallpaperPlugin)
protocol WallpaperPlugin: NSObjectProtocol {
    init()
    func setAsWallpaper(path: String) -> Bool
}
