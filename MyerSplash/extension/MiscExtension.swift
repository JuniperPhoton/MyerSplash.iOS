import Foundation
import UIKit
import Nuke
import MaterialComponents.MDCRippleTouchController

extension ImageCache {
    static func isCached(urlString: String?) -> Bool {
        guard let url = urlString else {
            return false
        }

        let request = Nuke.ImageRequest(url: URL(string: url)!)
        return ImageCache.shared[request] != nil
    }
}

func showToast(_ text: String) {
    guard let view = UIApplication.shared.keyWindow?.rootViewController?.view else {
        Log.warn(tag: "showtoast", "no active view")
        return
    }
    ToastView.Builder.init()
            .attachTo(view)
            .setMarginBottom(Dimensions.TOAST_MARGIN_BOTTOM)
            .setText(text)
            .build()
            .show()
}

extension UIView {
    func showToast(_ text: String) {
        ToastView.Builder.init()
                .attachTo(self)
                .setMarginBottom(Dimensions.TOAST_MARGIN_BOTTOM)
                .setText(text)
                .build()
                .show()
    }
}

extension UIApplication {
    func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }

    func versionBuild() -> String {
        let version = appVersion(), build = appBuild()

        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}

extension MDCRippleTouchController {
    static func load(intoView: UIView, withColor: UIColor? = nil, maxRadius: CGFloat? = nil) -> MDCRippleTouchController {
        let controller = MDCRippleTouchController(view: intoView)

        let rippleView = controller.rippleView
        rippleView.rippleStyle = .unbounded

        if let color = withColor {
            rippleView.rippleColor = color
            rippleView.activeRippleColor = color
        }

        if let radius = maxRadius {
            rippleView.maximumRadius = radius
        }
        return controller
    }
}

extension UIEdgeInsets {
    static func make(unifiedSize: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: CGFloat(unifiedSize), left: CGFloat(unifiedSize), bottom: CGFloat(unifiedSize), right: CGFloat(unifiedSize))
    }
}

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
