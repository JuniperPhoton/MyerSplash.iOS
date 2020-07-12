import Foundation
import UIKit
import Nuke
import SnapKit
import MaterialComponents.MDCRippleTouchController
import MyerSplashDesign

func showToast(_ text: String, time: TimeInterval = ToastView.STAYING_DURATION_SEC) {
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

extension UIView {
    func showToast(_ text: String) {
        ToastView.Builder.init()
                .attachTo(self)
                .setMarginBottom(Dimensions.ToastMarginBottom)
                .setText(text)
                .build()
                .show()
    }
}

extension ConstraintMaker {
    public func aspectRatioByWidth(_ x: CGFloat, by y: CGFloat, self instance: ConstraintView) {
        self.height.equalTo(instance.snp.width).multipliedBy(y / x)
    }
    
    public func aspectRatioByHeight(_ x: CGFloat, by y: CGFloat, self instance: ConstraintView) {
        self.width.equalTo(instance.snp.height).multipliedBy(x / y)
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

extension MDCRippleTouchController {
    static func load(view: UIView) -> MDCRippleTouchController {
        return MDCRippleTouchController.load(intoView: view,
                                             withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3),
                                             maxRadius: 25)
    }
}

extension UICollectionViewCell {
    func invalidateLayer() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: Dimensions.ShadowOffsetY)
        layer.shadowRadius = Dimensions.ShadowRadius.toCGFloat()
        layer.shadowOpacity = Dimensions.ShadowOpacity
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
    }
}
