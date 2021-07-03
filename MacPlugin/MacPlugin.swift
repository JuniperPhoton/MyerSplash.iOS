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
    
    var item: NSStatusItem? = nil
    
    private var onSetTodayWallpaper: (() -> Void)? = nil
    private var onSetRandomWallpaper: (() -> Void)? = nil
    private var onToggleDock: ((Bool) -> Void)? = nil

    func deactivateStatusItem() {
        item = nil
    }
    
    func toggleDock(show: Bool) {
        if (!show) {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }

    func activateStatusItem(configConverter: (StatusItemConfig) -> String,
                            onToggleDock: @escaping (Bool) -> Void,
                            onSetTodayWallpaper: @escaping () -> Void,
                            onSetRandomWallpaper: @escaping () -> Void) {
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
                
        self.onSetTodayWallpaper = onSetTodayWallpaper
        self.onSetRandomWallpaper = onSetRandomWallpaper
        self.onToggleDock = onToggleDock
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
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func exitApp() {
        NSApp.terminate(nil)
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
