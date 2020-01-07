import Foundation
import UIKit

protocol SettingsDelegate: class {
    func refresh()
}

class SettingsViewController: BaseViewController, UIViewControllerTransitioningDelegate,
        SettingsViewDelegate, SingleChoiceDelegate {
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

    func showDialog(content: DialogContent, key: String) {
        singleChoiceKey = key
        let vc = DialogViewController(dialogContent: content)
        vc.delegate = self
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        present(vc, animated: true)
    }

    func onItemSelected(index: Int) {
        guard let singleChoiceKey = singleChoiceKey else {
            return
        }

        UserDefaults.standard.set(index, forKey: singleChoiceKey)
        settingsView.updatingSingleChoiceSelected(selectedIndex: index, key: singleChoiceKey)
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInTransitioning()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeOutTransitioning()
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
