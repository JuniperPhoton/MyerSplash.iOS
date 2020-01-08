import Foundation
import UIKit

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
        singleChoiceKey = key
        let vc = DialogViewController(dialogContent: content)
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        present(vc, animated: true)
    }
    
    func onClickClose(shouldRefreshWhenDismiss: Bool) {
        print("onclick close")
        self.dismiss(animated: true)
        if (shouldRefreshWhenDismiss) {
            self.delegate?.refresh()
        }
    }
    
    func present(vc: UIViewController) {
        self.present(vc, animated: true, completion: nil)
    }
}


extension SettingsViewController: SingleChoiceDelegate {
    // MARK: SingleChoiceDelegate
    func onItemSelected(index: Int) {
        guard let singleChoiceKey = singleChoiceKey else {
            return
        }

        UserDefaults.standard.set(index, forKey: singleChoiceKey)
        settingsView.updatingSingleChoiceSelected(selectedIndex: index, key: singleChoiceKey)
    }
}
