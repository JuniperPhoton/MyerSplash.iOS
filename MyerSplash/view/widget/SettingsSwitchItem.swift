import Foundation
import UIKit
import SnapKit
import MyerSplashShared

class SettingsSwitchItem: SettingsItem {
    private var switchButton: UISwitch!

    private (set) var key: String?

    var checked: Bool = true {
        didSet {
            switchButton.isOn = checked
        }
    }

    var onCheckedChanged: ((Bool) -> Void)?

    convenience init(_ key: String) {
        self.init(frame: CGRect.zero)
        self.key = key
        updateSwitchByKey()
    }

    override func initUi() {
        super.initUi()

        switchButton = UISwitch()
        switchButton.onTintColor = Colors.THEME.asUIColor()
        switchButton.addTarget(self, action: #selector(onSwitchStatusChanged), for: .valueChanged)

        addSubview(switchButton)

        switchButton.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.snp.right).offset(-Dimensions.TitleMargin)
            maker.centerY.equalTo(self)
        }
    }

    private func updateSwitchByKey() {
        if let key = key {
            switchButton.isOn = UserDefaults.standard.bool(key: key, defaultValue: true)
        }
    }

    override func onClick() {
        super.onClick()
        switchButton.setOn(!switchButton.isOn, animated: true)
        onSwitchStatusChanged()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    @objc
    private func onSwitchStatusChanged() {
        if let key = key {
            UserDefaults.standard.set(switchButton.isOn, forKey: key)
            onCheckedChanged?(switchButton.isOn)
        }
    }
}
