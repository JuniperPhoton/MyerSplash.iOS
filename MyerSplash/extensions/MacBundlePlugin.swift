//
//  MacBundlePlugin.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2021/6/7.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation

class MacBundlePlugin {
    static let sharedInstance: Plugin? = {
        let bundleFileName = "MacPlugin.bundle"
        guard let bundleURL = Bundle.main.builtInPlugInsURL?
                .appendingPathComponent(bundleFileName) else { return nil}
        
        /// 2. Create a bundle instance with the plugin URL
        guard let bundle = Bundle(url: bundleURL) else { return nil}
        
        /// 3. Load the bundle and our plugin class
        let className = "MacPlugin.MacPlugin"
        guard let pluginClass = bundle.classNamed(className) as? Plugin.Type else { return nil}
        
        /// 4. Create an instance of the plugin class
        let plugin = pluginClass.init()
        return plugin
    }()
}
