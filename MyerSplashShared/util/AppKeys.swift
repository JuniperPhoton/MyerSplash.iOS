//
//  Keys.swift
//  MyerSplash
//
//  Created by MAC on 2019/11/5.
//  Copyright © 2019 juniper. All rights reserved.
//

import Foundation

public class AppKeys {
    public static let KEY_PLIST_NAME = "Key"
    public static let UNSPLASH_KEY_NAME = "UnsplashKey"
    public static let APP_CENTER_KEY_NAME = "AppCenterKey"

    private static var clientId: String = ""
    private static var appCenterKey: String = ""

    public static func prepare() {
        var keyDict: NSDictionary?
        if let path = Bundle.main.path(forResource: KEY_PLIST_NAME, ofType: "plist") {
            keyDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = keyDict {
            clientId = (dict.value(forKey: UNSPLASH_KEY_NAME) as? String) ?? ""
            appCenterKey = (dict.value(forKey: APP_CENTER_KEY_NAME) as? String) ?? ""
        }
    }

    public static func getClientId() -> String {
        if clientId.isEmpty {
            prepare()
        }

        return clientId
    }

    public static func getAppCenterKey() -> String {
        if appCenterKey.isEmpty {
            prepare()
        }

        return appCenterKey
    }
}
