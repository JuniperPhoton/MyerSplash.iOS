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

    override func loadView() {
        guard let dialogContent = dialogContent else {
            return
        }

        let rootView = UIView()
        rootView.backgroundColor = Colors.DIALOG_MASK.asUIColor()
        rootView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                             action: #selector(self.onClickBackground)))

        dialogContentView = UIView()
        dialogContentView.backgroundColor = UIColor("1e1e1e")
        dialogContentView.addGestureRecognizer(UITapGestureRecognizer())

        titleView = UILabel()
        titleView.text = dialogContent.title?.uppercased()
        titleView.textColor = UIColor.white
        titleView.font = titleView.font.with(traits: .traitBold, fontSize: 20)

        dialogContentView.addSubview(titleView)

        initDialogContentView(dialogContentView)

        rootView.addSubview(dialogContentView)

        dialogContentView.snp.makeConstraints { maker in
            maker.width.equalTo(UIScreen.main.bounds.width * 0.85)
            maker.height.equalTo(230)
            maker.center.equalTo(rootView)
        }

        titleView.snp.makeConstraints { maker in
            maker.left.top.equalTo(dialogContentView).offset(20)
        }

        view = rootView
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
            contentView.textColor = UIColor.white
            contentView.font = contentView.font.withSize(14)

            dialogContentView.addSubview(contentView)

            contentView.snp.makeConstraints { maker in
                maker.left.right.equalTo(dialogContentView)
                maker.top.equalTo(titleView).offset(20)
            }
        }
    }

    @objc
    private func onClickBackground() {
        dismiss(animated: true)
    }
}
