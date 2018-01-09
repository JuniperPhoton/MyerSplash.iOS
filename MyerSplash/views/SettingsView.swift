import Foundation
import UIKit

class SettingsView: UIView {
    private var titleView: UILabel!
    private var closeView: UIButton!

    var onClickClose: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.black

        titleView = UILabel()
        titleView.textColor = UIColor.white
        titleView.text = "SETTINGS"
        titleView.font = titleView.font.with(traits: .traitBold, fontSize: 25)

        closeView = UIButton()
        closeView.setImage(UIImage(named: "ic_clear_white"), for: .normal)
        closeView.addTarget(self, action: #selector(onClickCloseButton), for: .touchUpInside)

        addSubview(titleView)
        addSubview(closeView)

        titleView.snp.makeConstraints { maker in
            maker.left.equalTo(self.snp.left).offset(12)
            maker.top.equalTo(self.snp.top).offset(40)
        }
        closeView.snp.makeConstraints { maker in
            maker.width.height.equalTo(30)
            maker.right.equalTo(self.snp.right).offset(-12)
            maker.top.equalTo(titleView.snp.top)
            maker.bottom.equalTo(titleView.snp.bottom)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc
    private func onClickCloseButton() {
        onClickClose?()
    }
}