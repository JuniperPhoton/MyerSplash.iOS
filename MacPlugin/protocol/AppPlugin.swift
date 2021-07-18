//
//  AppPlugin.swift
//  MacPlugin
//
//  Created by juniperphoton on 2021/7/18.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation

@objc(AppPlugin)
protocol AppPlugin: NSObjectProtocol {
    init()
    func isSupportStatusBarFeature() -> Bool
}
