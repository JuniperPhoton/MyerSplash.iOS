import Foundation
import UIKit
import Nuke
import SnapKit
import MaterialComponents.MDCRippleTouchController

public func showToast(_ text: String, time: TimeInterval = ToastView.STAYING_DURATION_SEC) {
    guard let view = UIApplication.shared.getTopViewController()?.view else {
        Log.warn(tag: "showtoast", "no active view")
        return
    }
    ToastView.Builder()
            .attachTo(view)
            .setMarginBottom(Dimensions.ToastMarginBottom)
            .setText(text)
            .build()
            .show(time)
}

public extension UIView {
    func showToast(_ text: String) {
        ToastView.Builder.init()
                .attachTo(self)
                .setMarginBottom(Dimensions.ToastMarginBottom)
                .setText(text)
                .build()
                .show()
    }
}

public extension ConstraintMaker {
    func aspectRatioByWidth(_ x: CGFloat, by y: CGFloat, self instance: ConstraintView) {
        self.height.equalTo(instance.snp.width).multipliedBy(y / x)
    }
    
    func aspectRatioByHeight(_ x: CGFloat, by y: CGFloat, self instance: ConstraintView) {
        self.width.equalTo(instance.snp.height).multipliedBy(x / y)
    }
}

extension UIApplication {
    public func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    public func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }

    public func versionBuild() -> String {
        let version = appVersion(), build = appBuild()

        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}

extension MDCRippleTouchController {
    public static func load(intoView: UIView, withColor: UIColor? = nil, maxRadius: CGFloat? = nil) -> MDCRippleTouchController {
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
    public func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    public func remove() {
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

public extension UIApplication {
    func getTopViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.presentedViewController ?? self.keyWindow?.rootViewController
    }
}

public extension MDCRippleTouchController {
    static func load(view: UIView) -> MDCRippleTouchController {
        return MDCRippleTouchController.load(intoView: view,
                                             withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3),
                                             maxRadius: 25)
    }
}
