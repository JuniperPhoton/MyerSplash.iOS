//
//  NewUpdatesViewController.swift
//  MyerSplash
//
//  Created by juniperphoton on 2021/7/4.
//  Copyright © 2021 juniper. All rights reserved.
//

import Foundation
import UIKit
import MyerSplashShared
import MaterialComponents.MDCRippleTouchController

class NewUpdatesViewController: BaseViewController {
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.getDefaultBackgroundUIColor()
        return view
    }()
    
    private let titleView: UILabel = {
        let label = UILabel()
        label.text = R.strings.new_update_title
        label.textColor = UIColor.getDefaultLabelUIColor()
        label.font = label.font.with(traits: .traitBold, fontSize: 25)
        return label
    }()
    
    private let descView: UILabel = {
        let label = UILabel()
        label.text = R.strings.new_update_desc
        label.textColor = UIColor.getDefaultLabelUIColor()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "asset_updates")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor.getDefaultLabelUIColor()
        return button
    }()
    
    private var closeRippleController: MDCRippleTouchController!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.preferredContentSize = CGSize(width: 500, height: 350)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(backgroundView)
        self.view.addSubview(titleView)
        self.view.addSubview(descView)
        self.view.addSubview(imageView)
        self.view.addSubview(closeButton)
        
        closeRippleController = MDCRippleTouchController.load(intoView: closeButton,
                withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3),
                maxRadius: 25)
        
        closeButton.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.pin.all()
        titleView.pin.sizeToFit().topLeft(24)
        closeButton.pin.size(24).topRight(24)
        descView.pin.topLeft(to: titleView.anchor.bottomLeft).marginTop(12).right().sizeToFit(.width)
        imageView.pin.below(of: descView).left().bottom().right().margin(24)
    }
    
    @objc func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }
}
