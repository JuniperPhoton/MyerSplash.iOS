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

struct Keyword {
    var displayTitle: String!
    var query: String!
}

class SearchHintView: UIView {
    let builtInKeywords = [Keyword(displayTitle: "🔍 Minimalist", query: "Minimalist"),
              Keyword(displayTitle: "🏗 Buildings", query: "Buildings"),
              Keyword(displayTitle: "🍰 Food", query: "Food"),
              Keyword(displayTitle: "🗻 Nature", query: "Nature"),
              Keyword(displayTitle: "📱 Technology", query: "Technology"),
              Keyword(displayTitle: "🏖 Coastal", query: "Coastal"),
              Keyword(displayTitle: "✈️ Travel", query: "Travel"),
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
    
    fileprivate let rootFlexContainer = UIView()

    var onClickKeyword: ((Keyword) -> Void)? = nil
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .getDefaultBackgroundUIColor()
        
        rootFlexContainer.flex.direction(.row).padding(12).define { (flex) in
            var index = 0
            builtInKeywords.forEach { (keyword) in
                let root = UIView()
                root.backgroundColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3)
                root.layer.cornerRadius = Dimensions.SMALL_ROUND_CORNOR.toCGFloat();
                root.clipsToBounds = true
                
                let uiLabel = UIButton()
                uiLabel.setTitle(keyword.displayTitle, for: .normal)
                uiLabel.setTitleColor(UIColor.getDefaultLabelUIColor(), for: .normal)
                uiLabel.tag = index
                uiLabel.addTarget(self, action: #selector(onClickItem(button:)), for: .touchUpInside)
                
                //root.addSubview(uiLabel)
                
//                uiLabel.snp.makeConstraints { (maker) in
//                    let margin = 5
//                    maker.edges.equalToSuperview()
////                    maker.left.equalToSuperview().offset(margin)
////                    maker.right.equalToSuperview().offset(-margin)
////                    maker.top.equalToSuperview().offset(margin)
////                    maker.bottom.equalToSuperview().offset(-margin)
//                }
                
                flex.addItem(uiLabel)
                
                index = index + 1
            }
        }
        
        addSubview(rootFlexContainer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        // Layout the flexbox container using PinLayout
        // NOTE: Could be also layouted by setting directly rootFlexContainer.frame
        rootFlexContainer.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }

        // Then let the flexbox container layout itself
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    @objc
    private func onClickItem(button: UIButton) {
        let index = button.tag
        if (index < 0 || index >= builtInKeywords.count) {
            return
        }
        let keyword = builtInKeywords[index]
        onClickKeyword?(keyword)
    }
}
