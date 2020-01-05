import Foundation
import UIKit
import SnapKit

protocol DialogContent {
    var title: String? { get set }
}

class AlertDialog: DialogContent {
    var title:   String? = nil
    private (set) var  content: String? = nil

    init(title: String?, content: String?) {
        self.title = title
        self.content = content
    }
}

class SingleChoiceDialog: DialogContent {
    private (set) var  options:  [String]? = nil
    private (set) var  selected: Int       = 0
    var title:    String?   = nil

    init(title: String?, options: [String], selected: Int) {
        self.title = title
        self.options = options
        self.selected = selected
    }
}

protocol SingleChoiceDelegate {
    func onItemSelected(index: Int)
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         layer.mask = mask
     }
}

class DialogViewController: BaseViewController {
    private var titleView:         UILabel!
    private var dialogContentView: UIView!

    private var dialogContent: DialogContent?

    var delegate: SingleChoiceDelegate? = nil

    init(dialogContent: DialogContent) {
        super.init(nibName: nil, bundle: nil)
        self.dialogContent = dialogContent
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override func viewDidLoad() {
        guard let dialogContent = dialogContent else {
            return
        }

        dialogContentView = UIView()
        dialogContentView.backgroundColor = UIView.getDefaultDialogBackgroundUIColor()
        dialogContentView.addGestureRecognizer(UITapGestureRecognizer())
        dialogContentView.layer.cornerRadius = 12
        dialogContentView.clipsToBounds = true
        dialogContentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        titleView = UILabel()
        titleView.text = dialogContent.title?.uppercased()
        titleView.textColor = UIColor.getDefaultLabelUIColor()
        titleView.font = titleView.font.with(traits: .traitBold, fontSize: 20)

        dialogContentView.addSubview(titleView)

        initDialogContentView(dialogContentView)

        titleView.snp.makeConstraints { maker in
            maker.left.top.equalTo(dialogContentView).offset(20)
        }
        
        self.view.addSubview(dialogContentView)
        
        dialogContentView.snp.makeConstraints { (maker) in
            maker.left.top.right.bottom.equalToSuperview()
        }
    }

    private func initDialogContentView(_ dialogContentView: UIView) {
        if (dialogContent is SingleChoiceDialog) {
            let choiceContent = dialogContent as! SingleChoiceDialog

            let radioGroup = RadioButtonGroup(
                    options: choiceContent.options!,
                    selected: choiceContent.selected)
            radioGroup.onItemClicked = { i in
                self.delegate?.onItemSelected(index: i)
                self.dismiss(animated: true)
            }
            dialogContentView.addSubview(radioGroup)

            radioGroup.snp.makeConstraints { maker in
                maker.left.right.equalTo(dialogContentView)
                maker.top.equalTo(titleView.snp.bottom).offset(20)
            }
        } else if (dialogContent is AlertDialog) {
            let alertDialog = dialogContent as! AlertDialog

            let contentView = UILabel()
            contentView.text = alertDialog.content
            contentView.textColor = UIColor.getDefaultLabelUIColor()
            contentView.font = contentView.font.withSize(14)

            dialogContentView.addSubview(contentView)

            contentView.snp.makeConstraints { maker in
                maker.left.right.equalTo(dialogContentView)
                maker.top.equalTo(titleView).offset(20)
            }
        }
    }
}
