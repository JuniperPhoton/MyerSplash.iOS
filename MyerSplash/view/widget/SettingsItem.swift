import Foundation
import UIKit
import SnapKit
import MaterialComponents

class SettingsItem: UIView {
    private var label: UILabel!
    private var contentView: UILabel!
    
    private var rippleController: MDCRippleTouchController!

    var title: String? {
        didSet {
            label.text = title
        }
    }

    var content: String? {
        didSet {
            contentView.text = content
        }
    }

    var onClicked: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUi()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open func initUi() {
        label = UILabel()
        label.setDefaultLabelColor()
        label.font = label.font.withSize(FontSizes.contentFontSize)

        contentView = UILabel()
        contentView.setDefaultLabelColor()
        contentView.font = label.font.withSize(FontSizes.contentFontSize)
        contentView.alpha = 0.3

        let uiStack = UIStackView()
        uiStack.axis = NSLayoutConstraint.Axis.vertical
        uiStack.spacing = 8

        uiStack.addArrangedSubview(label)
        uiStack.addArrangedSubview(contentView)

        addSubview(uiStack)

        uiStack.snp.makeConstraints { maker in
            maker.centerY.equalTo(self)
            maker.left.equalTo(self).offset(Dimensions.TitleMargin)
            maker.topMargin.equalTo(10)
            maker.bottomMargin.equalTo(10)
        }

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClick)))
        
        rippleController = MDCRippleTouchController()
        rippleController.addRipple(to: self)
        rippleController.rippleView.rippleColor = R.colors.rippleColor
    }

    @objc
    open func onClick() {
        onClicked?()
    }
}
