import Foundation
import UIKit
import SnapKit

protocol NavigationViewDelegate {
    func onClickSettings()
    func onClickTitle()
}

public class MainNavigationView: UIView {
    private var titleView: UILabel!
    private var settingsView: UIButton!
    private var backgroundView: UIVisualEffectView!

    var title: String = "NEW" {
        didSet {
            titleView.text = title
        }
    }

    var delegate: NavigationViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        titleView = UILabel(frame: CGRect.zero)
        titleView.font = titleView.font.with(traits: .traitBold, fontSize: FontSizes.TITLE_FONT_SIZE)
        titleView.textColor = UIColor.white
        titleView.text = title
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickTitle)))

        settingsView = UIButton(frame: CGRect.zero)
        settingsView.setImage(UIImage(named: "ic_more_horiz_white"), for: .normal)
        settingsView.addTarget(self, action: #selector(onClickSettings), for: .touchUpInside)

        addSubview(titleView)
        addSubview(settingsView)

        titleView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(12)
            maker.centerY.equalTo(self).offset(12)
        }
        settingsView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(Dimensions.NAVIGATION_ICON_SIZE)
            maker.centerY.equalTo(self).offset(12)
            maker.right.equalTo(self.snp.right).offset(-12)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc
    private func onClickSettings() {
        delegate?.onClickSettings()
    }

    @objc
    private func onClickTitle() {
        delegate?.onClickTitle()
    }
}