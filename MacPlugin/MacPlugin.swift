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

    // MARK: Status bar
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
    
    @objc func exitApp() {
        NSApp.terminate(nil)
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
    
    // MARK: launch
    private var currentMainWindow: NSWindow? = nil
    
    @objc func launchApp() {
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
    
    func onAppDidLaunch() {
        NotificationCenter.default.addObserver(self, selector: #selector(onWindowBecomeMain), name: NSWindow.didBecomeMainNotification, object: nil)
    }
    
    private func createBlurView() -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = .underWindowBackground
        v.blendingMode = .behindWindow
        v.autoresizingMask = [.width, .height]
        return v
    }
    
    @objc func onWindowBecomeMain(notification: Notification) {
        currentMainWindow = notification.object as? NSWindow
        
        if let contentView = currentMainWindow?.contentView {
            let v = createBlurView()
            v.frame = contentView.bounds
            contentView.addSubview(v, positioned: NSWindow.OrderingMode.below, relativeTo: nil)
        }
    }
    
    func addBlurView(view: NSObject) {
        if let nsView = view as? NSView {
            let v = createBlurView()
            v.frame = nsView.bounds
            nsView.addSubview(v)
        }
    }
}
