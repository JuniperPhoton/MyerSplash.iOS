//
//  SearchHintView.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/7.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import FlexLayout
import UIKit
import PinLayout
import MyerSplashShared

struct Keyword: Hashable {
    var displayTitle: String!
    var query: String!
}

class SearchHintView: UIView {
    static let builtInKeywords = [Keyword(displayTitle: "🔍 Minimalist", query: "Minimalist"),
              Keyword(displayTitle: "🏗 Buildings", query: "Buildings"),
              Keyword(displayTitle: "📰 Current Events", query: "Current Events"),
              Keyword(displayTitle: "🚋 Street", query: "Street"),
              Keyword(displayTitle: "🍰 Food", query: "Food"),
              Keyword(displayTitle: "🎞️ Film", query: "Film"),
              Keyword(displayTitle: "🗻 Nature", query: "Nature"),
              Keyword(displayTitle: "📱 Technology", query: "Technology"),
              Keyword(displayTitle: "🏖 Coastal", query: "Coastal"),
              Keyword(displayTitle: "✈️ Travel", query: "Travel"),
              Keyword(displayTitle: "👕 Fashion", query: "Fashion"),
              Keyword(displayTitle: "👀 People", query: "People"),
              Keyword(displayTitle: "🏀 Sport", query: "Sport"),
              Keyword(displayTitle: "❄️ Snow", query: "Snow"),
              Keyword(displayTitle: "🌊 Sea", query: "Sea"),
              Keyword(displayTitle: "🌄 Dusk", query: "Dusk"),
              Keyword(displayTitle: "🌋 Mountain", query: "Mountain"),
              Keyword(displayTitle: "🌌 Galaxy", query: "Galaxy"),
              Keyword(displayTitle: "❤️ Red", query: "Red"),
              Keyword(displayTitle: "🧡 Orange", query: "Orange"),
              Keyword(displayTitle: "💛 Yellow", query: "Yellow"),
              Keyword(displayTitle: "💚 Green", query: "Green"),
              Keyword(displayTitle: "💙 Blue", query: "Blue"),
              Keyword(displayTitle: "💜 Purple", query: "Purple"),
              Keyword(displayTitle: "⚫️ Black", query: "Black"),
              Keyword(displayTitle: "⚪️ White", query: "White"),
    ]
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.contentSize = CGSize(width: 300, height: 300)
        return v
    }()
    
    let rootFlexContainer = UIView()

    var onClickKeyword: ((Keyword) -> Void)? = nil
    var onLayout: ((CGSize) -> Void)? = nil

    init() {
        super.init(frame: .zero)
        
        let margin: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 24 : 12
        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12

        rootFlexContainer.flex.direction(.row).justifyContent(.start).wrap(.wrap).padding(12).define { (flex) in
            var index = 0
            SearchHintView.builtInKeywords.forEach { (keyword) in
                let uiLabel = UIButton()
                uiLabel.setTitle(keyword.displayTitle, for: .normal)
                uiLabel.titleLabel?.font = uiLabel.titleLabel?.font.withSize(fontSize)
                uiLabel.setTitleColor(UIColor.getDefaultLabelUIColor(), for: .normal)
                uiLabel.tag = index
                uiLabel.addTarget(self, action: #selector(onClickItem(button:)), for: .touchUpInside)
                
                flex.addItem(uiLabel).margin(margin)
                
                index = index + 1
            }
        }
                
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        let size = rootFlexContainer.flex.width(self.frame.width).intrinsicSize
        onLayout?(size)
        
        scrollView.pin.all(pin.safeArea)

        // Layout the flexbox container using PinLayout
        // NOTE: Could be also layouted by setting directly rootFlexContainer.frame
        rootFlexContainer.pin.all(pin.safeArea)
        
        // Then let the flexbox container layout itself
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        let w = rootFlexContainer.bounds.width
        let h = rootFlexContainer.bounds.height
        scrollView.contentSize = CGSize(width: w, height: h)
    }
    
    @objc
    private func onClickItem(button: UIButton) {
        let index = button.tag
        if (index < 0 || index >= SearchHintView.builtInKeywords.count) {
            return
        }
        let keyword = SearchHintView.builtInKeywords[index]
        onClickKeyword?(keyword)
        
        Events.trackClickSearchItem(name: keyword.query)
    }
}
