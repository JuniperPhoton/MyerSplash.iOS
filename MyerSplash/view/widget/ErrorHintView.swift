import Foundation
import UIKit
import MaterialComponents.MDCActivityIndicator
import MaterialComponents.MDCFlatButton
import MyerSplashShared

class ErrorHintView: UIView {
    var onClickRetry: (()->Void)? = nil
    
    var mdcButton : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let title = UILabel()
        title.text = R.strings.uh_oh
        title.textColor = UIColor.getDefaultLabelUIColor()
        title.font = title.font.with(traits: .traitBold).withSize(32)
        
        let desc = UILabel()
        desc.text = R.strings.something_wrong
        desc.textColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.7)
        desc.font = desc.font.withSize(17)
        desc.numberOfLines = 10
        
        mdcButton = MDCFlatButton()
        mdcButton.setTitle(R.strings.retry, for: .normal)
        mdcButton.setTitleColor(.getDefaultLabelUIColor(), for: .normal)
        mdcButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 50, bottom: 12, right: 50)
        mdcButton.addTarget(self, action: #selector(invokeRetry), for: .touchUpInside)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(desc)
        stack.addArrangedSubview(mdcButton)

        addSubview(stack)

        stack.snp.makeConstraints { (maker) in
            maker.center.equalTo(self.snp.center)
        }
        
        stack.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc
    func invokeRetry() {
        print("on click retry")
        onClickRetry?()
    }
}
