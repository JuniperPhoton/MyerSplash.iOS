//
//  Plugin.swift
//  MacPlugin
//
//  Created by JuniperPhoton on 2021/6/6.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation

@objc(Plugin)
protocol Plugin: NSObjectProtocol {
    init()

    func setAsWallpaper(path: String) -> Bool
}
