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

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    #if targetEnvironment(macCatalyst)
    private let space = CGFloat(30)
    #else
    private let space = CGFloat(20)
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.getDefaultBackgroundUIColor()

        let rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.alignment = .center
        rootStack.distribution = .fill
        rootStack.spacing = 12

        let appNameStack = UIStackView()
        appNameStack.axis = .horizontal
        appNameStack.alignment = .center
        appNameStack.distribution = .fill
        
        #if targetEnvironment(macCatalyst)
        let largeTitleFontSize = CGFloat(50)
        #else
        let largeTitleFontSize = CGFloat(32)
        #endif

        let myerLabel = UILabel()
        myerLabel.text = "Myer"
        myerLabel.textColor = UIColor.getDefaultLabelUIColor()
        myerLabel.font = myerLabel.font.with(traits: .traitBold).withSize(largeTitleFontSize)
        myerLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        let splashLabel = UILabel()
        splashLabel.text = "Splash"
        splashLabel.textColor = UIColor.getDefaultLabelUIColor()
        splashLabel.font = splashLabel.font.with(traits: .traitBold).withSize(largeTitleFontSize)
        splashLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        let logo = UIImageView()
        logo.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        logo.image = UIImage(named: R.icons.ic_app_icon)
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true

        appNameStack.addArrangedSubview(logo)
        appNameStack.addArrangedSubview(myerLabel)
        appNameStack.addArrangedSubview(splashLabel)

        logo.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(50)
        }

        let platformsLabel = UILabel()
        platformsLabel.text = "for Windows 10, macOS, iOS and Android"
        platformsLabel.textColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        platformsLabel.font = platformsLabel.font.withSize(FontSizes.contentFontSize)

        let versionsRoot = UIView()
        versionsRoot.backgroundColor = Colors.THEME.asUIColor()
        versionsRoot.layer.cornerRadius = Dimensions.SmallRoundCornor.toCGFloat();
        versionsRoot.clipsToBounds = true

        let versionsLabel = UILabel()
        versionsLabel.text = "Versions \(UIApplication.shared.appVersion())"
        versionsLabel.textColor = UIColor.white
        versionsLabel.font = platformsLabel.font.with(traits: .traitBold).withSize(FontSizes.contentFontSize)

        versionsRoot.addSubview(versionsLabel)

        versionsLabel.snp.makeConstraints { (maker) in
            let margin = 7
            maker.left.equalToSuperview().offset(margin)
            maker.right.equalToSuperview().offset(-margin)
            maker.top.equalToSuperview().offset(margin)
            maker.bottom.equalToSuperview().offset(-margin)
        }

        let creditLabel = createTitleLabel(R.strings.about_credit)

        let creditText = UILabel()
        creditText.text = R.strings.about_credit_content
        creditText.textColor = UIColor.getDefaultLabelUIColor()
        creditText.font = platformsLabel.font.withSize(FontSizes.contentFontSize)
        creditText.lineBreakMode = .byTruncatingTail
        creditText.numberOfLines = 100
        creditText.textAlignment = .center

        let feedbackLabel = createTitleLabel(R.strings.about_feedback)
        
        let feedbackInsets = UIEdgeInsets(top: 12, left: 50, bottom: 12, right: 50)

        let feedBackButton = MDCFlatButton()
        feedBackButton.setTitle(R.strings.about_feedback_email, for: .normal)
        feedBackButton.setTitleColor(UIColor.getDefaultLabelUIColor(), for: .normal)
        feedBackButton.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
        feedBackButton.contentEdgeInsets = feedbackInsets
        feedBackButton.showsTouchWhenHighlighted = false
        feedBackButton.inkColor = R.colors.rippleColor
        feedBackButton.setTitleFont(platformsLabel.font.withSize(FontSizes.contentFontSize), for: .normal)
        
        let gitHubButton = MDCFlatButton()
        gitHubButton.setTitle("GitHub", for: .normal)
        gitHubButton.setTitleColor(UIColor.getDefaultLabelUIColor(), for: .normal)
        gitHubButton.addTarget(self, action: #selector(openGitHub), for: .touchUpInside)
        gitHubButton.contentEdgeInsets = feedbackInsets
        gitHubButton.showsTouchWhenHighlighted = false
        gitHubButton.inkColor = R.colors.rippleColor
        gitHubButton.setTitleFont(platformsLabel.font.withSize(FontSizes.contentFontSize), for: .normal)

        let webButton = MDCFlatButton()
        webButton.setTitle(R.strings.about_website, for: .normal)
        webButton.setTitleColor(UIColor.getDefaultLabelUIColor(), for: .normal)
        webButton.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
        webButton.contentEdgeInsets = feedbackInsets
        webButton.showsTouchWhenHighlighted = false
        webButton.inkColor = R.colors.rippleColor
        webButton.setTitleFont(platformsLabel.font.withSize(FontSizes.contentFontSize), for: .normal)

        rootStack.addArrangedSubview(appNameStack)
        rootStack.addArrangedSubview(platformsLabel)
        rootStack.addArrangedSubview(versionsRoot)
        rootStack.addArrangedSubview(creditLabel)
        rootStack.addArrangedSubview(creditText)
        rootStack.addArrangedSubview(feedbackLabel)
        rootStack.addArrangedSubview(feedBackButton)
        rootStack.addArrangedSubview(gitHubButton)
        rootStack.addArrangedSubview(webButton)

        rootStack.setCustomSpacing(space, after: versionsRoot)
        rootStack.setCustomSpacing(space, after: creditText)
        rootStack.setCustomSpacing(0, after: feedBackButton)
        rootStack.setCustomSpacing(0, after: gitHubButton)
        rootStack.setCustomSpacing(0, after: webButton)

        self.view.addSubview(rootStack)

        rootStack.snp.makeConstraints { (maker) in
            #if targetEnvironment(macCatalyst)
            maker.width.equalTo(600)
            #else
            maker.width.equalTo(300)
            #endif
            maker.centerY.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
    }
    
    @objc
    private func openGitHub() {
        UIApplication.shared.open(URL(string: "https://github.com/JuniperPhoton/MyerSplash.iOS")!,
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
