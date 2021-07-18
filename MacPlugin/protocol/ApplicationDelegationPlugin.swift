//
//  ApplicationDelegationPlugin.swift
//  MacPlugin
//
//  Created by juniperphoton on 2021/7/15.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation

@objc(ApplicationDelegationPlugin)
protocol ApplicationDelegationPlugin: NSObjectProtocol {
    init()
    func onAppDidLaunch()
    func launchApp()
    func exitApp()
    func toggleDockIcon(show: Bool)
}
