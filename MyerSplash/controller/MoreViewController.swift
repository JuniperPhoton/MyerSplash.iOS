//
//  MoreViewController.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/6.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import Tabman
import Pageboy
import UIKit
import MaterialComponents.MDCRippleTouchController

class MoreViewController: TabmanViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            appStatusBarStyle
        }
    }

    private var closeRippleController: MDCRippleTouchController!

    private var viewControllers = [DownloadsViewController(),
                                   SettingsViewController(),
                                   AboutViewController()]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.getDefaultBackgroundUIColor()
        
        self.dataSource = self

        let bar = createTopTabBar()
        bar.layout.contentInset = UIEdgeInsets(top: 20, left: 20.0, bottom: 0.0, right: 50)
        
        addBar(bar, dataSource: self, at: .top)
        
        let closeButton = UIButton()
        let closeImage = UIImage.init(named: "ic_clear_white")!.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        closeButton.backgroundColor = UIColor.getDefaultBackgroundUIColor()
        closeButton.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
        closeRippleController = MDCRippleTouchController.load(intoView: closeButton,
                                                              withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3),
                                                              maxRadius: 25)
        
        closeButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(bar.layout.view.snp.top)
            maker.bottom.equalTo(bar.layout.view.snp.bottom)
            maker.right.equalToSuperview().offset(-10)
            maker.width.equalTo(50)
        }
    }
    
    @objc
    private func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

extension MoreViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title: String!
        switch index {
        case 0:
            title = "DOWNLOADS"
        case 1:
            title = "SETTINGS"
        case 2:
            title = "ABOUT"
        default:
            title = ""
        }
        let item = TMBarItem(title: title)
        return item
    }

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        .at(index: 1)
    }
}