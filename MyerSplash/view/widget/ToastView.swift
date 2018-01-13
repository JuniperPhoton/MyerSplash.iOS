import Foundation
import SnapKit
import UIKit

class ToastView: UILabel {
    static let PADDING = CGFloat(8)
    static let SHOWING_HIDING_DURATION_SEC = 0.2
    static let STAYING_DURATION_SEC = 2.0

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

            let tv = ToastView(frame: CGRect.zero)
            tv.text = text

            root.addSubview(tv)

            tv.snp.makeConstraints { maker in
                maker.bottom.equalTo(root).offset(-marginBottom)
                maker.centerX.equalTo(root)
            }

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

        UIView.animateKeyframes(withDuration: overallDuration, delay: 0.0, animations: { () -> Void in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: relativeShowingDuration) {
                self.alpha = 1.0
            }

            UIView.addKeyframe(withRelativeStartTime: 1 - relativeShowingDuration, relativeDuration: relativeShowingDuration) {
                self.alpha = 0.0
            }
        }, completion: { b in
            self.removeFromSuperview()
        })
    }

    private func initUi() {
        self.layer.cornerRadius = Dimensions.RECT_CORNER_RADIUS_NORMAL
        self.layer.backgroundColor = Colors.THEME.asCGColor()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.4

        self.alpha = 0.0
        self.font = self.font.withSize(FontSizes.NORMAL)

        self.snp.makeConstraints { maker in
            maker.height.equalTo(Dimensions.TOAST_HEIGHT)
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect,
                UIEdgeInsetsMake(0, ToastView.PADDING, 0, ToastView.PADDING)))
    }
}
