import Foundation
import UIKit
import SnapKit

class SettingsItem: UIView {
    private var label: UILabel!
    private var contentView: UILabel!

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
        label.textColor = UIColor.white
        label.font = label.font.withSize(FontSizes.NORMAL)

        contentView = UILabel()
        contentView.textColor = UIColor.white
        contentView.font = label.font.withSize(FontSizes.NORMAL)
        contentView.alpha = 0.5

        let uiStack = UIStackView()
        uiStack.axis = UILayoutConstraintAxis.vertical
        uiStack.spacing = 8

        uiStack.addArrangedSubview(label)
        uiStack.addArrangedSubview(contentView)

        addSubview(uiStack)

        uiStack.snp.makeConstraints { maker in
            maker.centerY.equalTo(self)
            maker.left.equalTo(self).offset(12)
        }

        snp.makeConstraints { maker in
            maker.height.equalTo(Dimensions.SETTING_ITEM_HEIGHT)
        }

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClick)))
    }

    @objc
    open func onClick() {
        onClicked?()
    }
}