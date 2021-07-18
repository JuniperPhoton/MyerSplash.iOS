//
//  MacBundlePlugin.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2021/6/7.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation

class MacBundlePlugins {
    static let sharedWallpaperPlugin: WallpaperPlugin? = {
        guard let bundle = createBundle() else { return nil}
        
        /// 3. Load the bundle and our plugin class
        let className = "MacPlugin.MacWallpaperPlugin"
        guard let pluginClass = bundle.classNamed(className) as? WallpaperPlugin.Type else { return nil}
        
        /// 4. Create an instance of the plugin class
        let plugin = pluginClass.init()
        return plugin
    }()
    
    static let sharedApplicationDelegationPlugin: ApplicationDelegationPlugin? = {
        guard let bundle = createBundle() else { return nil}
        
        /// 3. Load the bundle and our plugin class
        let className = "MacPlugin.MacApplicationDelegationPlugin"
        guard let pluginClass = bundle.classNamed(className) as? ApplicationDelegationPlugin.Type else { return nil}
        
        /// 4. Create an instance of the plugin class
        let plugin = pluginClass.init()
        return plugin
    }()
    
    static let sharedStatusBarPlugin: StatusBarPlugin? = {
        guard let bundle = createBundle() else { return nil}
        
        let className = "MacPlugin.MacStatusBarPlugin"
        guard let pluginClass = bundle.classNamed(className) as? StatusBarPlugin.Type else { return nil}
        
        let plugin = pluginClass.init()
        return plugin
    }()
    
    static let sharedAppPlugin: AppPlugin? = {
        guard let bundle = createBundle() else { return nil}
        
        let className = "MacPlugin.MacAppPlugin"
        guard let pluginClass = bundle.classNamed(className) as? AppPlugin.Type else { return nil}
        
        let plugin = pluginClass.init()
        return plugin
    }()
    
    private static func createBundle() -> Bundle? {
        let bundleFileName = "MacPlugin.bundle"
        guard let bundleURL = Bundle.main.builtInPlugInsURL?
                .appendingPathComponent(bundleFileName) else { return nil}
        
        /// 2. Create a bundle instance with the plugin URL
        return Bundle(url: bundleURL)
    }
}
