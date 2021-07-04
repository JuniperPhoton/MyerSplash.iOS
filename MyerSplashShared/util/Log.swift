//
//  Log.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/10.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation

public class Log {
    private init() {

    }

    public static func info(tag: String, _ text: String) {
        #if DEBUG
        printInternal(tag: tag, level: "info", text: text)
        #endif
    }

    public static func warn(tag: String, _ text: String) {
        #if DEBUG
        printInternal(tag: tag, level: "warn", text: text)
        #endif
    }

    public static func error(tag: String, _ text: String) {
        #if DEBUG
        printInternal(tag: tag, level: "error", text: text)
        #endif
    }

    private static func printInternal(tag: String, level: String, text: String) {
        #if DEBUG
        var tagEmoji = ""
        if (level == "info") {
            tagEmoji = "⌨️"
        } else if (level == "warn") {
            tagEmoji = "⚠️"
        } else if (level == "error") {
            tagEmoji = "❌"
        }
        print("\(tagEmoji) \(tag), \(level): \(text)")
        #endif
    }
}
