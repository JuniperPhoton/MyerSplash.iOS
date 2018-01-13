import Foundation
import UIKit

open class BaseViewController: UIViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setNeedsStatusBarAppearanceUpdate()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func showToast(_ text: String) {
        ToastView.Builder.init()
                .attachTo(self.view)
                .setMarginBottom(Dimensions.TOAST_MARGIN_BOTTOM)
                .setText(text)
                .build().show()
    }
}