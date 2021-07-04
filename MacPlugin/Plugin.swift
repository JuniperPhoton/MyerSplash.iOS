//
//  Plugin.swift
//  MacPlugin
//
//  Created by JuniperPhoton on 2021/6/6.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation

enum StatusItemKind {
    case Launch
    case ToggleDock
    case SetHighlight
    case SetRandom
    case Exit
}

public class StatusItemConfig: NSObject {
    private(set) var kind: StatusItemKind = .Launch
    
    convenience init(kind: StatusItemKind) {
        self.init()
        self.kind = kind
    }
}

@objc(Plugin)
protocol Plugin: NSObjectProtocol {
    init()

    func setAsWallpaper(path: String) -> Bool
    func deactivateStatusItem()
    func activateStatusItem(configConverter: (StatusItemConfig) -> String,
                            onToggleDock: @escaping (Bool) -> Void,
                            onSetTodayWallpaper: @escaping () -> Void,
                            onSetRandomWallpaper: @escaping () -> Void)
    func toggleDock(show: Bool)
    func onAppDidLaunch()
}
