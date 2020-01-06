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

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
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

        let myerLabel = UILabel()
        myerLabel.text = "Myer"
        myerLabel.textColor = UIColor.getDefaultLabelUIColor()
        myerLabel.font = myerLabel.font.withSize(26)
        myerLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let splashLabel = UILabel()
        splashLabel.text = "Splash"
        splashLabel.textColor = UIColor.getDefaultLabelUIColor()
        splashLabel.font = splashLabel.font.with(traits: .traitBold).withSize(26)
        splashLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let logo = UIImageView()
        logo.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        logo.image = UIImage.init(named: "Image")
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        
        appNameStack.addArrangedSubview(logo)
        appNameStack.addArrangedSubview(myerLabel)
        appNameStack.addArrangedSubview(splashLabel)

        logo.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(50)
        }

        let platformsLabel = UILabel()
        platformsLabel.text = "for Windows 10, Android and iOS"
        platformsLabel.textColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        platformsLabel.font = platformsLabel.font.withSize(13)
        
        let versionsRoot = UIView()
        versionsRoot.backgroundColor = Colors.THEME.asUIColor()
        versionsRoot.layer.cornerRadius = Dimensions.SMALL_ROUND_CORNOR.toCGFloat();
        versionsRoot.clipsToBounds = true
        
        let versionsLabel = UILabel()
        versionsLabel.text = "Versions \(UIApplication.shared.appVersion())"
        versionsLabel.textColor = UIColor.white
        versionsLabel.font = platformsLabel.font.with(traits: .traitBold).withSize(13)
        
        versionsRoot.addSubview(versionsLabel)
        
        versionsLabel.snp.makeConstraints { (maker) in
            let margin = 5
            maker.left.equalToSuperview().offset(margin)
            maker.right.equalToSuperview().offset(-margin)
            maker.top.equalToSuperview().offset(margin)
            maker.bottom.equalToSuperview().offset(-margin)
        }
        
        let creditLabel = createTitleLabel("CREDIT")
        
        let creditText = UILabel()
        creditText.text = "Photos are from Unsplash, an amazing website providing free high-resolution photos."
        creditText.textColor = UIColor.getDefaultLabelUIColor()
        creditText.font = platformsLabel.font.withSize(13)
        creditText.lineBreakMode = .byTruncatingTail
        creditText.numberOfLines = 100
        creditText.textAlignment = .center
        
        let feedbackLabel = createTitleLabel("FEEDBACK")
        
        let feedBackButton = UIButton(type: .system)
        feedBackButton.setTitle("Email me", for: .normal)
        feedBackButton.setTitleColor(UIColor.getDefaultLabelUIColor(), for: .normal)
        feedBackButton.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
        
        rootStack.addArrangedSubview(appNameStack)
        rootStack.addArrangedSubview(platformsLabel)
        rootStack.addArrangedSubview(versionsRoot)
        rootStack.addArrangedSubview(creditLabel)
        rootStack.addArrangedSubview(creditText)
        rootStack.addArrangedSubview(feedbackLabel)
        rootStack.addArrangedSubview(feedBackButton)

        rootStack.setCustomSpacing(20, after: versionsRoot)
        rootStack.setCustomSpacing(20, after: creditText)

        self.view.addSubview(rootStack)
        
        rootStack.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
            maker.centerY.equalToSuperview()
        }
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
       composeVC.setMessageBody("Hello from developer. Please write you suggestions below. Thanks!", isHTML: false)

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
        title.font = title.font.with(traits: .traitBold).withSize(17)
        
        return title
    }
}
