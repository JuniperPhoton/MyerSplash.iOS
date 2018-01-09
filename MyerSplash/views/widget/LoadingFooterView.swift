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

        //stack = UIStackView(frame: CGRect.zero)
        //stack.axis = UILayoutConstraintAxis.horizontal
        //stack.addArrangedSubview(ac)
        //stack.addArrangedSubview(label)
        //stack.backgroundColor = UIColor.red

        //addSubview(stack)
    }

    override func updateConstraints() {
        stack.snp.makeConstraints { (maker) in
            maker.top.bottom.equalTo(self)
            maker.centerX.equalTo(self.snp.centerX)
        }
//        ac.snp.makeConstraints { (maker) in
//            maker.width.height.equalTo(50)
//            maker.left.greaterThanOrEqualTo(self.snp.left)
//            maker.right.equalTo(label.snp.left)
//            maker.top.equalTo(self.snp.top)
//            maker.bottom.equalTo(self.snp.bottom)
//        }
//
//        label.snp.makeConstraints { (maker) in
//            maker.left.equalTo(ac.snp.right)
//            maker.right.lessThanOrEqualTo(self.snp.right)
//            maker.top.equalTo(self.snp.top)
//            maker.bottom.equalTo(self.snp.bottom)
//        }
        super.updateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
