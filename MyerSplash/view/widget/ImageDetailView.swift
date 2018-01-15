import Foundation
import UIKit
import SnapKit
import Nuke

protocol ImageDetailViewDelegate {
    func onHidden()
    func onRequestImageDownload(image: UnsplashImage)
    func onRequestOpenUrl(urlString: String)
}

class ImageDetailView: UIView {
    private var mainImageView:        UIImageView!
    private var backgroundView:       UIView!
    private var extraInformationView: UIView!
    private var photoByLabel:         UILabel!
    private var authorButton:         UIButton!
    private var authorStack:          UIStackView!
    private var downloadButton:       UIButton!

    private var initFrame: CGRect?        = nil
    private var bindImage: UnsplashImage? = nil

    var delegate: ImageDetailViewDelegate? = nil

    private var finalFrame: CGRect {
        get {
            let width      = self.frame.width
            let height     = MainViewController.calculateCellHeight(width)
            let x: CGFloat = 0.0
            let y: CGFloat = (self.frame.height - height - Dimensions.IMAGE_DETAIL_EXTRA_HEIGHT) / 2.0
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        initUi()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func show(initFrame: CGRect, image: UnsplashImage) {
        self.initFrame = initFrame
        self.bindImage = image
        bind()
        showInternal()
    }

    private func initUi() {
        backgroundView = UIView()
        backgroundView.backgroundColor = Colors.DIALOG_MASK.asUIColor()
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(onClickBackground)))
        mainImageView = UIImageView(frame: CGRect.zero)
        mainImageView.contentMode = UIViewContentMode.scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self,
                                                                  action: #selector(onMotionEvent)))

        extraInformationView = UIView()
        extraInformationView.isHidden = true

        photoByLabel = UILabel()
        photoByLabel.font = photoByLabel.font.withSize(FontSizes.SMALL)

        authorButton = UIButton()
        authorButton.titleLabel!.font = authorButton.titleLabel!.font.with(traits: .traitBold, fontSize: FontSizes.LARGE)
        authorButton.titleLabel!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        authorButton.addTarget(self, action: #selector(onClickAuthorName), for: .touchUpInside)

        authorStack = UIStackView(arrangedSubviews: [photoByLabel, authorButton])
        authorStack.axis = UILayoutConstraintAxis.vertical
        authorStack.spacing = 2

        downloadButton = UIButton()
        downloadButton.setTitle("DOWNLOAD", for: .normal)
        downloadButton.layer.cornerRadius = Dimensions.RECT_CORNER_RADIUS_NORMAL
        downloadButton.titleLabel!.font = downloadButton.titleLabel!.font.with(traits: .traitBold,
                                                                               fontSize: FontSizes.NORMAL)
        downloadButton.addTarget(self, action: #selector(onClickDownloadButton), for: .touchUpInside)

        let inset = UIEdgeInsetsMake(8, 8, 8, 8);
        downloadButton.contentEdgeInsets = inset

        downloadButton.sizeToFit()

        extraInformationView.addSubview(authorStack)
        extraInformationView.addSubview(downloadButton)

        addSubview(backgroundView)
        addSubview(extraInformationView)
        addSubview(mainImageView)

        backgroundView.snp.makeConstraints { maker in
            maker.width.equalTo(UIScreen.main.bounds.width)
            maker.height.equalTo(UIScreen.main.bounds.height)
        }

        extraInformationView.snp.makeConstraints { maker in
            maker.width.equalTo(UIScreen.main.bounds.width)
            maker.height.equalTo(Dimensions.IMAGE_DETAIL_EXTRA_HEIGHT)
            maker.bottom.equalTo(self.mainImageView.snp.bottom)
        }

        authorStack.snp.makeConstraints { maker in
            maker.left.equalTo(self.extraInformationView.snp.left).offset(12)
            maker.right.lessThanOrEqualTo(downloadButton.snp.left).offset(-8)
            maker.centerY.equalTo(self.extraInformationView.snp.centerY)
        }

        downloadButton.snp.makeConstraints { maker in
            maker.width.equalTo(self.downloadButton.frame.width)
            maker.centerY.equalTo(self.extraInformationView.snp.centerY)
            maker.right.equalTo(self.extraInformationView.snp.right).offset(-20)
        }
    }

    private var startX: CGFloat = -1
    private var startY: CGFloat = -1

    @objc
    private func onMotionEvent(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
            case UIGestureRecognizerState.began:
                startX = mainImageView.center.x
                startY = mainImageView.center.y
                extraInformationView.isHidden = true
            case UIGestureRecognizerState.changed:
                mainImageView.center.x = startX + translation.x
                mainImageView.center.y = startY + translation.y
            case UIGestureRecognizerState.ended:
                hideInternal()
            default:
                return
        }
    }

    @objc
    private func onClickDownloadButton() {
        guard let bindImage = bindImage else {
            return
        }
        delegate?.onRequestImageDownload(image: bindImage)
    }

    @objc
    private func onClickAuthorName() {
        guard let url = bindImage?.userHomePage else {
            return
        }
        delegate?.onRequestOpenUrl(urlString: url)
    }

    @objc private func onClickBackground() {
        hideInternal()
    }

    private func bind() {
        guard let initFrame = initFrame,
              let image = bindImage else {
            return
        }
        mainImageView.frame = initFrame
        Manager.shared.loadImage(with: URL(string: image.listUrl!)!, into: mainImageView)

        let themeColor   = image.themeColor
        let isThemeLight = themeColor.isLightColor()

        extraInformationView.backgroundColor = themeColor

        photoByLabel.text = image.isUnsplash ? "photo by" : "recommended by"

        let textColor       = isThemeLight ? UIColor.black : UIColor.white
        let revertTextColor = isThemeLight ? UIColor.white : UIColor.black

        photoByLabel.textColor = textColor

        var attrs = [NSAttributedStringKey: Any]()
        attrs[NSAttributedStringKey.foregroundColor] = textColor
        attrs[NSAttributedStringKey.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
        let underlineAttributedString = NSAttributedString(string: image.userName!, attributes: attrs)
        authorButton.setAttributedTitle(underlineAttributedString, for: .normal)

        downloadButton.setTitleColor(revertTextColor, for: .normal)
        downloadButton.backgroundColor = textColor
    }

    private func showInternal() {
        self.backgroundView.alpha = 0.0
        isHidden = false

        UIView.animate(withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                           self.backgroundView.alpha = 1.0
                           self.mainImageView.frame = self.finalFrame
                       },
                       completion: { b in
                           self.showExtraInformation()
                       })
    }

    private func showExtraInformation() {
        extraInformationView.isHidden = false

        extraInformationView.snp.remakeConstraints { maker in
            maker.width.equalTo(UIScreen.main.bounds.width)
            maker.height.equalTo(Dimensions.IMAGE_DETAIL_EXTRA_HEIGHT)
            maker.top.equalTo(self.mainImageView.snp.bottom)
        }

        UIView.animate(withDuration: Values.A_BIT_SLOW_ANIMATION_DURATION_SEC,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                           self.layoutIfNeeded()
                       },
                       completion: nil)
    }

    private func hideInternal() {
        if (!self.extraInformationView.isHidden) {
            hideExtraInformationView {
                self.hideImage()
            }
        } else {
            hideImage()
        }
    }

    private func hideExtraInformationView(_ completion: (() -> Void)? = nil) {
        extraInformationView.snp.remakeConstraints { maker in
            maker.width.equalTo(UIScreen.main.bounds.width)
            maker.height.equalTo(Dimensions.IMAGE_DETAIL_EXTRA_HEIGHT)
            maker.bottom.equalTo(self.mainImageView.snp.bottom)
        }

        UIView.animate(withDuration: Values.A_BIT_SLOW_ANIMATION_DURATION_SEC,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                           self.layoutIfNeeded()
                       },
                       completion: { b in
                           self.extraInformationView.isHidden = true
                           completion?()
                       })
    }

    private func hideImage() {
        UIView.animate(withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                           self.backgroundView.alpha = 0.0
                           self.mainImageView.frame = self.initFrame!
                       },
                       completion: { b in
                           self.isHidden = true
                           self.extraInformationView.isHidden = true
                           self.delegate?.onHidden()
                       })
    }
}
