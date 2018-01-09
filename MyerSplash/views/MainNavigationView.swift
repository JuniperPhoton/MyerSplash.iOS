import Foundation
import UIKit
import SnapKit

public class MainNavigationView: UIView {
    private var titleView: UILabel!
    private var settingsView: UIButton!
    private var navigationBarView: UIView!
    private var backgroundView: UIVisualEffectView!

    var title: String = "NEW" {
        didSet {
            titleView.text = title
        }
    }

    var callback: NavigationViewCallback?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let blurEffect = UIBlurEffect(style: .dark)
        backgroundView = UIVisualEffectView()
        backgroundView.effect = blurEffect
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        titleView = UILabel(frame: CGRect.zero)
        titleView.font = titleView.font.with(traits: .traitBold, fontSize: 23)
        titleView.textColor = UIColor.white
        titleView.text = title
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickTitle)))

        settingsView = UIButton(frame: CGRect.zero)
        settingsView.setImage(UIImage(named: "ic_settings_white"), for: .normal)
        settingsView.addTarget(self, action: #selector(onClickSettings), for: .touchUpInside)

        navigationBarView = UIView()

        let layer = navigationBarView.layer
        layer.backgroundColor = Colors.ThemeDarkColor.asCGColor()

        let themeLayer = CALayer()
        themeLayer.backgroundColor = Colors.ThemeColor.asCGColor()
        themeLayer.frame = CGRect(x: 0, y: 0, width: 12, height: 5)
        layer.addSublayer(themeLayer)

        addSubview(backgroundView)
        addSubview(titleView)
        addSubview(navigationBarView)
        addSubview(settingsView)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func updateConstraints() {
        super.updateConstraints()
        titleView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(20)
            maker.centerY.equalTo(self).offset(10)
        }
        settingsView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(30)
            maker.centerY.equalTo(self).offset(15)
            maker.right.equalTo(self.snp.right).offset(-20)
        }
        navigationBarView.snp.makeConstraints { (maker) in
            maker.left.equalTo(titleView.snp.left)
            maker.right.equalTo(titleView.snp.right)
            maker.top.equalTo(titleView.snp.bottom).offset(4)
            maker.height.equalTo(5)
        }
    }

    @objc
    private func onClickSettings() {
        callback?.onClickSettings()
    }

    @objc
    private func onClickTitle() {
        callback?.onClickTitle()
    }
}

protocol NavigationViewCallback {
    func onClickSettings()
    func onClickTitle()
}
