import Foundation
import UIKit
import MyerSplashShared

protocol SettingsDelegate: AnyObject {
    func refresh()
}

class SettingsViewController: BaseViewController {
    private var settingsView: SettingsView!
    private var singleChoiceKey: String? = nil

    weak var delegate: SettingsDelegate?

    override func loadView() {
        self.definesPresentationContext = true
        settingsView = SettingsView()
        settingsView.delegate = self
        view = settingsView
    }

    @objc
    private func onClick() {
        dismiss(animated: true)
    }
}
