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
import MyerSplashShared

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
    
    private var selectedIndex = 0
    
    private lazy var statusbarPlaceholder: UIView = {
        let v = UIView()
        let blurView = UIView.makeBlurBackgroundView()
        v.addSubview(blurView)
        return v
    }()
    
    init(selectedIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        self.selectedIndex = selectedIndex
        
        #if targetEnvironment(macCatalyst)
        self.modalPresentationStyle = .fullScreen
        #else
        self.modalPresentationStyle = .pageSheet
        #endif
    }

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

        self.view.addSubview(statusbarPlaceholder)
        
        #if targetEnvironment(macCatalyst)
        let topOffset = UIView.topInset
        let barHeight = getTopBarHeight()
        #else
        let topOffset = UIView.topInset
        let barHeight = getTopBarHeight()
        #endif
        
        addBar(bar, dataSource: self, at: .custom(view: statusbarPlaceholder, layout: { (v) in
            v.frame = CGRect(x: 0, y: CGFloat(topOffset),
                             width: self.view.bounds.width - MainViewController.BAR_BUTTON_SIZE - MainViewController.BAR_BUTTON_RIGHT_MARGIN, height: barHeight)
        }))

        let closeButton = UIButton()
        let closeImage = UIImage(named: R.icons.ic_clear)!.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        closeButton.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        self.view.addSubview(closeButton)

        closeRippleController = MDCRippleTouchController.load(intoView: closeButton,
                withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3),
                maxRadius: 25)

        closeButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(bar.layout.view.snp.top)
            maker.bottom.equalTo(bar.layout.view.snp.bottom)
            maker.right.equalToSuperview().offset(-10)
            maker.width.equalTo(MainViewController.BAR_BUTTON_SIZE)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let statusBarHeight = getTopBarHeight() + UIView.topInset

        statusbarPlaceholder.pin.height(statusBarHeight).width(of: self.view).pinEdges()
    }

    @objc
    private func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}

extension MoreViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title: String!
        switch index {
        case 0:
            title = R.strings.tab_downloads
        case 1:
            title = R.strings.tab_settings
        case 2:
            title = R.strings.tab_about
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
        .at(index: selectedIndex)
    }
}
