//
//  AboutViewController.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/6.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import MaterialComponents.MDCRippleTouchController
import MyerSplashShared

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    #if targetEnvironment(macCatalyst)
    private let space = CGFloat(30)
    #else
    private let space = CGFloat(20)
    #endif
    
    #if targetEnvironment(macCatalyst)
    private let largeTitleFontSize = CGFloat(50)
    #else
    private lazy var largeTitleFontSize: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGFloat(40)
        } else {
            return CGFloat(32)
        }
    }()
    
    #endif
    
    private var feedbackRippleController: MDCRippleTouchController!
    private var githubRippleController: MDCRippleTouchController!
    private var twitterRippleController: MDCRippleTouchController!
    private var webRippleController: MDCRippleTouchController!

    private let feedbackInsets = UIEdgeInsets(top: 12, left: 50, bottom: 12, right: 50)
    
    private lazy var myerLabel: UILabel = {
        let myerLabel = UILabel()
        myerLabel.text = "Myer"
        myerLabel.textColor = UIColor.getDefaultLabelUIColor()
        myerLabel.font = myerLabel.font.light.withSize(largeTitleFontSize)
        return myerLabel
    }()
    
    private lazy var splashLabel: UILabel = {
        let splashLabel = UILabel()
        splashLabel.text = "Splash"
        splashLabel.textColor = UIColor.getDefaultLabelUIColor()
        splashLabel.font = splashLabel.font.with(traits: .traitBold).withSize(largeTitleFontSize)
        return splashLabel
    }()
    
    private lazy var logo: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: R.icons.ic_app_icon)
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        return logo
    }()
    
    private var logoContainer: UIView = {
        let container = UIView()
        return container
    }()
    
    private lazy var rootView: UIView = {
        let container = UIView()
        return container
    }()
    
    private lazy var detailsContainer: UIView = {
        let container = UIView()
        return container
    }()
    
    private lazy var platformsLabel: UILabel = {
        let platformsLabel = UILabel()
        platformsLabel.text = "for Windows 10, macOS, iOS and Android"
        platformsLabel.textColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        platformsLabel.font = platformsLabel.font.withSize(FontSizes.contentFontSize)
        return platformsLabel
    }()
    
    private lazy var versionsRoot: UIView = {
        let versionsRoot = UIView()
        versionsRoot.backgroundColor = Colors.THEME.asUIColor()
        versionsRoot.layer.cornerRadius = Dimensions.SmallRoundCornor.toCGFloat();
        versionsRoot.clipsToBounds = true
        return versionsRoot
    }()
    
    private lazy var versionsLabel: UILabel = {
        let versionsLabel = UILabel()
        versionsLabel.text = "Versions \(UIApplication.shared.appVersion())"
        versionsLabel.textColor = UIColor.white
        versionsLabel.font = platformsLabel.font.with(traits: .traitBold).withSize(FontSizes.contentFontSize)
        return versionsLabel
    }()
    
    private lazy var creditLabel: UILabel = {
        return createTitleLabel(R.strings.about_credit)
    }()
    
    private lazy var creditText: UILabel = {
        let creditText = UILabel()
        creditText.text = R.strings.about_credit_content
        creditText.textColor = UIColor.getDefaultLabelUIColor()
        creditText.font = platformsLabel.font.withSize(FontSizes.contentFontSize)
        creditText.numberOfLines = 0
        creditText.textAlignment = .center
        return creditText
    }()
    
    private lazy var feedbackLabel: UILabel = {
        return createTitleLabel(R.strings.about_feedback)
    }()
    
    private lazy var feedbackContainer: UIView = {
        return UIView()
    }()
    
    private lazy var feedbackButton: UIView = {
        let button = UIButton()
        let image = UIImage(named: "ic_mail")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
        button.tintColor = UIColor.getDefaultLabelUIColor()
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private lazy var githubButton: UIView = {
        let button = UIButton()
        let image = UIImage(named: "ic_github")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(openGitHub), for: .touchUpInside)
        button.tintColor = UIColor.getDefaultLabelUIColor()
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private lazy var twitterButton: UIView = {
        let button = UIButton()
        let image = UIImage(named: "ic_twitter")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(openTwitter), for: .touchUpInside)
        button.tintColor = UIColor.getDefaultLabelUIColor()
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private lazy var webButton: UIView = {
        let button = UIButton()
        let image = UIImage(named: "ic_home")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
        button.tintColor = UIColor.getDefaultLabelUIColor()
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.getDefaultBackgroundUIColor()
        
        logoContainer.addSubViews(logo, myerLabel, splashLabel)
        versionsRoot.addSubview(versionsLabel)
        
        feedbackContainer.addSubViews(feedbackButton, githubButton, twitterButton, webButton)
        
        rootView.addSubViews(logoContainer, platformsLabel, versionsRoot, creditLabel, creditText, feedbackLabel, feedbackContainer)
        
        view.addSubview(rootView)
        
        feedbackRippleController = MDCRippleTouchController.load(view: feedbackButton)
        githubRippleController = MDCRippleTouchController.load(view: githubButton)
        twitterRippleController = MDCRippleTouchController.load(view: twitterButton)
        webRippleController = MDCRippleTouchController.load(view: webButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margin = 12.cgFloat
        let iconSize = 32.cgFloat
        
        logo.pin.size(50)
        myerLabel.pin.right(of: logo, aligned: .center).marginLeft(margin).sizeToFit()
        splashLabel.pin.right(of: myerLabel, aligned: .center).sizeToFit()
        logoContainer.pin.center().wrapContent()
        
        platformsLabel.pin.below(of: logoContainer, aligned: .center).marginTop(margin).sizeToFit()
        versionsLabel.pin.all().sizeToFit()
        versionsRoot.pin.below(of: platformsLabel, aligned: .center).marginTop(margin).wrapContent(padding: margin / 2)
        
        creditLabel.pin.below(of: versionsRoot, aligned: .center).marginTop(margin * 2).sizeToFit()
        creditText.pin.below(of: creditLabel, aligned: .center)
            .maxWidth(300).marginTop(margin).marginLeft(margin).marginRight(margin).sizeToFit(.width)
        
        feedbackLabel.pin.below(of: creditText, aligned: .center).marginTop(margin * 2).sizeToFit()
        
        feedbackButton.pin.size(iconSize)
        githubButton.pin.after(of: feedbackButton).marginLeft(margin * 2).size(iconSize)
        twitterButton.pin.after(of: githubButton).marginLeft(margin * 2).size(iconSize)
        webButton.pin.after(of: twitterButton).marginLeft(margin * 2).size(iconSize)
        
        feedbackContainer.pin.below(of: feedbackLabel, aligned: .center).center().marginTop(margin).wrapContent()
        rootView.pin.wrapContent().center()
    }
    
    @objc
    private func openGitHub() {
        UIApplication.shared.open(URL(string: "https://github.com/JuniperPhoton/MyerSplash.iOS")!,
                                  options: [:], completionHandler: nil)
    }
    
    @objc
    private func openTwitter() {
        UIApplication.shared.open(URL(string: "https://twitter.com/JuniperPhoton")!,
                                  options: [:], completionHandler: nil)
    }
    
    @objc
    private func openWebsite() {
        UIApplication.shared.open(URL(string: "https://juniperphoton.dev/myersplash/")!,
                                  options: [:], completionHandler: nil)
    }
    
    @objc
    private func sendFeedback() {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["dengweichao@hotmail.com"])
        composeVC.setSubject("MyerSplash iOS feedback")
        composeVC.setMessageBody(R.strings.about_feedback_email_body, isHTML: false)
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func createTitleLabel(_ text: String) -> UILabel {
        let title = UILabel()
        title.text = text
        title.textColor = Colors.THEME.asUIColor()
        title.font = title.font.with(traits: .traitBold).withSize(FontSizes.titleFontSize)
        
        return title
    }
}
