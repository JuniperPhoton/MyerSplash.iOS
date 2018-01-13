import Foundation
import UIKit

class LoadingFooterView: UIView {
    private var ac: UIActivityIndicatorView!
    private var label: UILabel!
    private var stack: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        ac = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        ac.startAnimating()
        ac.color = UIColor.white
        addSubview(ac)

        label = UILabel()
        label.text = "LOADING..."
        label.textColor = UIColor.white
        addSubview(label)

        stack = UIStackView()
        stack.axis = UILayoutConstraintAxis.horizontal
        stack.addArrangedSubview(ac)
        stack.addArrangedSubview(label)
        stack.spacing = 12

        addSubview(stack)

        stack.snp.makeConstraints { (maker) in
            maker.top.bottom.equalTo(self)
            maker.centerX.equalTo(self.snp.centerX)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
