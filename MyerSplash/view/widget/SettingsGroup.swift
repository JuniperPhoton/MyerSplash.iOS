import Foundation
import UIKit
import SnapKit
import MyerSplashShared

class SettingsGroup: UIStackView {
    private var groupTitleView: UILabel!

    var label: String? {
        didSet {
            groupTitleView.text = label
        }
    }

    override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(self)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        axis = NSLayoutConstraint.Axis.vertical

        groupTitleView = UILabel()
        groupTitleView.textColor = Colors.THEME.asUIColor()
        groupTitleView.font = groupTitleView.font.with(traits: .traitBold, fontSize: FontSizes.Normal)

        addArrangedSubview(groupTitleView)

        groupTitleView.snp.remakeConstraints { (maker) in
            maker.left.equalTo(self).offset(Dimensions.TitleMargin)
            maker.top.equalTo(self).offset(12)
        }
        
        setCustomSpacing(12, after: groupTitleView)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
