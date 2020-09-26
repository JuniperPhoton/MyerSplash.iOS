import Foundation
import UIKit
import MyerSplashShared

protocol SettingsDelegate: class {
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

extension SettingsViewController: SettingsViewDelegate {
    // MARK: SettingsViewDelegate
    func showDialog(content: DialogContent, key: String) {
        let vc = DialogViewController(dialogContent: content)
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        present(vc, animated: true)
    }

    func present(vc: UIViewController) {
        self.present(vc, animated: true, completion: nil)
    }
}
