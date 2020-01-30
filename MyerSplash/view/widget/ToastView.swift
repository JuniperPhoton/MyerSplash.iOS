import Foundation
import SnapKit
import UIKit

class ToastView: UILabel {
    static let PADDING = CGFloat(10)
    static let SHOWING_HIDING_DURATION_SEC = 0.2
    static let STAYING_DURATION_SEC = 2.0
    
    private static var toast: ToastView? = nil

    /**
     Use the Builder of ToastView instead.
    **/
    class Builder {
        private var text: String? = nil
        private var marginBottom: Int = 0
        private var root: UIView? = nil

        init() {
        }

        /**
         Set content of the toast.
        **/
        func setText(_ text: String) -> Builder {
            self.text = text
            return self
        }

        /**
         Set how much the toast is above from the bottom of attached root view.
        **/
        func setMarginBottom(_ margin: Int) -> Builder {
            self.marginBottom = margin
            return self
        }

        /**
        Attach to a specified root view.
        **/
        func attachTo(_ root: UIView) -> Builder {
            self.root = root
            return self
        }

        /**
        Build the toast view. Normally the caller should call the show(:) method to make the view
        appear.
        **/
        func build() -> ToastView {
            guard let root = root else {
                fatalError("Root view should not be nil")
            }
            
            ToastView.toast?.removeFromSuperview()
            ToastView.toast = nil

            let tv = ToastView(frame: CGRect.zero)
            tv.text = text

            root.addSubview(tv)

            tv.snp.makeConstraints { maker in
                maker.bottom.equalTo(root).offset(-marginBottom)
                maker.centerX.equalTo(root)
            }

            ToastView.toast = tv
            
            return tv
        }
    }

    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.width += ToastView.PADDING * 2
            return contentSize
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUi()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func show(_ lastTimeSec: Double = ToastView.STAYING_DURATION_SEC) {
        let overallDuration = ToastView.SHOWING_HIDING_DURATION_SEC * 2 + lastTimeSec
        let relativeShowingDuration = ToastView.SHOWING_HIDING_DURATION_SEC / overallDuration

        UIView.animateKeyframes(withDuration: overallDuration,
                delay: 0.0,
                animations: { [weak self] () -> Void in
                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                            relativeDuration: relativeShowingDuration) {
                        self?.alpha = 1.0
                    }

                    UIView.addKeyframe(withRelativeStartTime: 1 - relativeShowingDuration,
                            relativeDuration: relativeShowingDuration) {
                        self?.alpha = 0.0
                    }
                },
                completion: { [weak self] b in
                    self?.removeFromSuperview()
                    ToastView.toast = nil
                })
    }

    private func initUi() {
        self.layer.cornerRadius = Dimensions.SMALL_ROUND_CORNOR.toCGFloat()
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = Dimensions.SHADOW_RADIUS.toCGFloat()
        self.layer.shadowOpacity = Dimensions.SHADOW_OPACITY
        self.layer.shadowOffset = CGSize(width: 0, height: Dimensions.SHADOW_OFFSET_Y)
        self.textColor = UIColor.black

        self.alpha = 0.0
        self.font = self.font.withSize(FontSizes.NORMAL)

        self.snp.makeConstraints { maker in
            maker.height.equalTo(Dimensions.TOAST_HEIGHT)
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: ToastView.PADDING, dy: 6))
    }
}
