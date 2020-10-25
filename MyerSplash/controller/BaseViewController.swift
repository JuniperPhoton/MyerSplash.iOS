import Foundation
import UIKit
import MyerSplashShared

extension UIColor {
    static var isDarkMode: Bool {
        get {
            return true
        }
    }
    
    func mixBlackInDarkMode()-> UIColor {
        if !UIColor.isDarkMode {
            return self
        }
        
        return UIColor.mdc_blendColor(UIColor.black.withAlphaComponent(0.3), withBackgroundColor:self)
    }
}

extension UIViewController {
    var appStatusBarStyle: UIStatusBarStyle {
        get {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return UIStatusBarStyle.lightContent
            } else {
                return UIStatusBarStyle.darkContent
            }
        }
    }
}

open class BaseViewController: UIViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            appStatusBarStyle
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}
