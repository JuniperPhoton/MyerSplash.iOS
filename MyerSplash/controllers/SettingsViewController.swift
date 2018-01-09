import Foundation
import UIKit

class SettingsViewController: UIViewController {
    private var settingsView: SettingsView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setNeedsStatusBarAppearanceUpdate()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        settingsView = SettingsView()
        view = settingsView
    }

    @objc func onClick() {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsView.onClickClose = {
            print("onclick close")
            self.dismiss(animated: true)
        }
    }
}