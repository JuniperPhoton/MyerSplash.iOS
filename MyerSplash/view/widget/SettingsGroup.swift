import Foundation
import UIKit
import SnapKit

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

        axis = UILayoutConstraintAxis.vertical
        spacing = 20.0

        groupTitleView = UILabel()
        groupTitleView.textColor = Colors.THEME.asUIColor()
        groupTitleView.font = groupTitleView.font.with(traits: .traitBold, fontSize: FontSizes.NORMAL)

        addArrangedSubview(groupTitleView)

        groupTitleView.snp.remakeConstraints { (maker) in
            maker.left.top.equalTo(self).offset(12)
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
