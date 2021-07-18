//
//  MacApplicationDelegationPlugin.swift
//  MacPlugin
//
//  Created by juniperphoton on 2021/7/15.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import AppKit

class MacApplicationDelegationPlugin: NSObject, ApplicationDelegationPlugin {
    private var currentMainWindow: NSWindow? = nil

    required override init() {
        // ignored
    }
    
    func toggleDockIcon(show: Bool) {
        if (!show) {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    func onAppDidLaunch() {
        NotificationCenter.default.addObserver(self, selector: #selector(onWindowBecomeMain), name: NSWindow.didBecomeMainNotification, object: nil)
    }
    
    @objc func onWindowBecomeMain(notification: Notification) {
        currentMainWindow = notification.object as? NSWindow
    }
    
    // MARK: launch
    func launchApp() {
        if let window = currentMainWindow {
            if window.isMiniaturized {
                window.deminiaturize(nil)
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func exitApp() {
        NSApp.terminate(nil)
    }
}
