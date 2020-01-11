//
//  Log.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/10.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation

class Log {
    private init() {

    }

    static func info(tag: String, _ text: String) {
        #if DEBUG
        printInternal(tag: tag, level: "info", text: text)
        #endif
    }

    static func warn(tag: String, _ text: String) {
        #if DEBUG
        printInternal(tag: tag, level: "warn", text: text)
        #endif
    }

    static func error(tag: String, _ text: String) {
        #if DEBUG
        printInternal(tag: tag, level: "error", text: text)
        #endif
    }

    private static func printInternal(tag: String, level: String, text: String) {
        #if DEBUG
        print("\(tag), \(level): \(text)")
        #endif
    }
}
