import Foundation
import UIKit

class FloatingActionButton: UIView {
    var onClick: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let roundLayer = CALayer()
        roundLayer.frame = CGRect(x: 0,
                y: 0,
                width: Dimensions.FAB_RADIUS,
                height: Dimensions.FAB_RADIUS)
        roundLayer.cornerRadius = CGFloat(Dimensions.FAB_RADIUS) / 2.0
        roundLayer.backgroundColor = UIColor.white.cgColor
        roundLayer.shadowColor = UIColor.black.cgColor
        roundLayer.shadowRadius = 5
        roundLayer.shadowOffset = CGSize(width: 5, height: 5)
        roundLayer.shadowOpacity = 0.3

        let imageLayer = CALayer()
        let image = UIImage(named: "ic_search_black")!
        imageLayer.contents = image.cgImage
        imageLayer.frame = CGRect(
                x: (Dimensions.FAB_RADIUS - Dimensions.FAB_ICON_SIZE) / 2,
                y: (Dimensions.FAB_RADIUS - Dimensions.FAB_ICON_SIZE) / 2,
                width: Dimensions.FAB_ICON_SIZE,
                height: Dimensions.FAB_ICON_SIZE)

        layer.addSublayer(roundLayer)
        layer.addSublayer(imageLayer)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self,
                action: #selector(onClickSelf)))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc
    private func onClickSelf() {
        print("fab onclick performed")
        onClick?()
    }
}
