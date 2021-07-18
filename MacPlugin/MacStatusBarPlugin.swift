//
//  MacStatusBarPlugin.swift
//  MacPlugin
//
//  Created by juniperphoton on 2021/7/15.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
#if !targetEnvironment(simulator)
import AppKit
#endif

class MacStatusBarPlugin: NSObject, StatusBarPlugin {
    var item: NSStatusItem? = nil
    
    private var onSetTodayWallpaper: (() -> Void)? = nil
    private var onSetRandomWallpaper: (() -> Void)? = nil
    private var onToggleDock: ((Bool) -> Void)? = nil
    
    private var onLaunchApp: (() -> Void)? = nil
    private var onExitApp: (() -> Void)? = nil

    required override init() {
        // ignored
    }
    
    func register(onToggleDock: @escaping (Bool) -> Void,
                  onSetTodayWallpaper: @escaping () -> Void,
                  onSetRandomWallpaper: @escaping () -> Void,
                  onLaunchApp: @escaping (() -> Void),
                  onExitApp: @escaping (() -> Void)) {
        self.onToggleDock = onToggleDock
        self.onSetTodayWallpaper = onSetTodayWallpaper
        self.onSetRandomWallpaper = onSetRandomWallpaper
        self.onLaunchApp = onLaunchApp
        self.onExitApp = onExitApp
    }
    
    func deactivateStatusItem() {
        item = nil
    }
    
    func activateStatusItem(configConverter: (StatusItemConfig) -> String) {
        if item != nil {
            return
        }
        
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        var statusMenu: NSMenu!
        statusMenu = NSMenu(title: "MyerSplash")
        
        let configs: [StatusItemConfig] = [
            StatusItemConfig(kind: .Launch),
            StatusItemConfig(kind: .ToggleDock),
            StatusItemConfig(kind: .SetHighlight),
            StatusItemConfig(kind: .SetRandom),
            StatusItemConfig(kind: .Exit)
        ]
                
        for c in configs {
            var selector: Selector? = nil
            switch c.kind {
            case .Launch:
                selector = #selector(launchApp)
            case .ToggleDock:
                selector = #selector(toggleDockIcon)
            case .SetHighlight:
                selector = #selector(setTodayWallpaper)
            case .SetRandom:
                selector = #selector(setRandomWallpaper)
            case .Exit:
                selector = #selector(exitApp)
            }
            statusMenu.addItem(withTitle: configConverter(c), action: selector, keyEquivalent: "").target = self
        }

        let icon = NSImage(named: "ic_status")
        item?.button?.image = icon
        item?.menu = statusMenu
    }
    
    @objc func toggleDockIcon() {
        let showDock = NSApp.activationPolicy() == .accessory
        toggleDock(show: showDock)
        self.onToggleDock?(showDock)
    }
    
    @objc func setTodayWallpaper() {
        self.onSetTodayWallpaper?()
    }
    
    @objc func setRandomWallpaper() {
        self.onSetRandomWallpaper?()
    }
    
    @objc func launchApp() {
        self.onLaunchApp?()
    }
    
    @objc func exitApp() {
        self.onExitApp?()
    }
    
    func toggleDock(show: Bool) {
        if (!show) {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
}
