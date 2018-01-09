import Foundation
import UIKit

class FloatingActionButton: UIView {
    var onClick: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let imageLayer = CALayer()
        let image = UIImage(named: "ic_search_white")!
        imageLayer.contents = image.cgImage
        imageLayer.frame = CGRect(x: 20, y: 20, width: 30, height: 30)

        let roundLayer = CALayer()
        roundLayer.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        roundLayer.cornerRadius = 25
        roundLayer.backgroundColor = Colors.ThemeColor.asCGColor()
        roundLayer.shadowColor = UIColor.black.cgColor
        roundLayer.shadowRadius = 5
        roundLayer.shadowOffset = CGSize(width: 5, height: 5)
        roundLayer.shadowOpacity = 0.3

        layer.addSublayer(roundLayer)
        layer.addSublayer(imageLayer)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickSelf)))
    }

    @objc
    private func onClickSelf() {
        print("fab onclick performed")
        onClick?()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
