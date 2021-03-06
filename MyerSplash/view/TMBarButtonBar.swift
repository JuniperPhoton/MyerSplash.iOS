//
//  TMBarButtonBar.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/6.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import Tabman
import Pageboy
import MyerSplashShared

func createTopTabBar() -> TMBar.ButtonBar {
    let bar = TMBar.ButtonBar()
    bar.layout.transitionStyle = .snap
    bar.layout.alignment = .leading
    bar.layout.contentInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 20, right: 20)
    bar.backgroundView.style = .flat(color: .clear)
    bar.fadesContentEdges = true
    bar.scrollMode = .swipe

    let isEnglish = NSLocalizedString("lang_code", comment: "") == "en_us"
    var fontSize = isEnglish ? 13 : 14
    var spacing = isEnglish ? 8 : 12
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        fontSize = Int(fontSize.toCGFloat() * 1.3)
        spacing = Int(spacing.toCGFloat() * 2)
        bar.layout.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 15, right: 20)
    }
    
    #if targetEnvironment(macCatalyst)
    bar.layout.contentInset = UIEdgeInsets(top: 40, left: 20, bottom: 20, right: 20)
    #endif

    bar.layout.interButtonSpacing = CGFloat(spacing)
    bar.buttons.customize { (button) in
        button.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3)
        button.selectedTintColor = UIColor.getDefaultLabelUIColor()
        button.font = UIFont.preferredFont(forTextStyle: .largeTitle).with(traits: .traitBold).withSize(CGFloat(fontSize))
    }
    bar.indicator.tintColor = UIColor.getDefaultLabelUIColor()
    bar.indicator.weight = .custom(value: 4)
    
    return bar
}
