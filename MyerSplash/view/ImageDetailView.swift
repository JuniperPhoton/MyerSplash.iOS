import Foundation
import UIKit
import SnapKit
import Nuke
import RxSwift
import AVFoundation.AVUtilities

protocol ImageDetailViewDelegate: class {
    func onHidden()
    func onRequestImageDownload(image: UnsplashImage)
    func onRequestOpenUrl(urlString: String)
    func onRequestEdit(item: DownloadItem)
}

class ImageDetailView: UIView {
    private var mainImageView: DayNightImageView!
    private var backgroundView: UIView!
    private var extraInformationView: UIView!
    private var photoByLabel: UILabel!
    private var authorButton: UIButton!
    private var authorStack: UIStackView!
    private var downloadButton: DownloadButton!
    private var downloadRoot: UIView!
    
    private(set) lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: R.icons.ic_share), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(onClickShare), for: .touchUpInside)
        return button
    }()

    private var initFrame: CGRect? = nil
    private var bindImage: UnsplashImage? = nil

    weak var delegate: ImageDetailViewDelegate? = nil

    private var progressLayer: CALayer!

    private var disposable: Disposable? = nil

    private var finalFrame: CGRect {
        get {
            let rawRatio = bindImage!.getAspectRatioF(viewWidth: self.frame.width, viewHeight: self.frame.height)

            let fixedHorizontalMargin: CGFloat
            let fixedVerticalMargin: CGFloat
            
            let fixedInfoHeight = Dimensions.ImageDetailExtraHeight

            if UIDevice.current.userInterfaceIdiom == .pad {
                fixedHorizontalMargin = 50
                fixedVerticalMargin = 70
            } else {
                fixedHorizontalMargin = 0
                fixedVerticalMargin = 0
            }
            
            let rect = AVMakeRect(aspectRatio: CGSize(width: rawRatio, height: 1.0),
                                  insideRect: CGRect(x: fixedHorizontalMargin, y: fixedVerticalMargin,
                                                     width: self.frame.width - fixedHorizontalMargin * 2,
                                                     height: self.frame.height - fixedVerticalMargin * 2 - fixedInfoHeight))
            
            return rect
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

    // MARK: UI
    private func initUi() {
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.getDefaultBackgroundUIColor().withAlphaComponent(0.5)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                action: #selector(onClickBackground)))

        mainImageView = DayNightImageView()
        mainImageView.contentMode = UIView.ContentMode.scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self,
                action: #selector(onMotionEvent)))

        extraInformationView = UIView()
        extraInformationView.isHidden = true

        photoByLabel = UILabel()
        photoByLabel.font = photoByLabel.font.withSize(FontSizes.Large)

        authorButton = UIButton()
        authorButton.titleLabel!.font = authorButton.titleLabel!.font.with(traits: .traitBold, fontSize: FontSizes.Large)
        authorButton.titleLabel!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        authorButton.addTarget(self, action: #selector(onClickAuthorName), for: .touchUpInside)

        authorStack = UIStackView(arrangedSubviews: [photoByLabel, authorButton])
        authorStack.axis = NSLayoutConstraint.Axis.vertical
        authorStack.spacing = 2

        downloadRoot = UIView()
        progressLayer = CALayer()
        downloadRoot.layer.addSublayer(progressLayer)
        downloadRoot.layer.masksToBounds = true
        downloadRoot.layer.cornerRadius = CGFloat(Dimensions.SmallRoundCornor)
        
        downloadButton = DownloadButton()
        downloadButton.addTarget(self, action: #selector(onClickDownloadButton), for: .touchUpInside)
        downloadRoot.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        extraInformationView.addSubview(authorStack)
        extraInformationView.addSubview(downloadRoot)
        extraInformationView.addSubview(shareButton)

        addSubview(backgroundView)
        addSubview(extraInformationView)
        addSubview(mainImageView)

        backgroundView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        extraInformationView.snp.makeConstraints { maker in
            maker.left.equalTo(mainImageView.snp.left)
            maker.right.equalTo(mainImageView.snp.right)
            maker.height.equalTo(Dimensions.ImageDetailExtraHeight)
            maker.bottom.equalTo(self.mainImageView.snp.bottom)
        }

        authorStack.snp.makeConstraints { maker in
            maker.left.equalTo(self.extraInformationView.snp.left).offset(12)
            maker.right.lessThanOrEqualTo(shareButton.snp.left).offset(-8)
            maker.centerY.equalTo(self.extraInformationView.snp.centerY)
        }

        downloadRoot.snp.makeConstraints { maker in
            maker.width.equalTo(100)
            maker.centerY.equalTo(self.extraInformationView.snp.centerY)
            maker.right.equalTo(self.extraInformationView.snp.right).offset(-12)
        }
        
        shareButton.snp.makeConstraints { (maker) in
            maker.right.equalTo(downloadRoot.snp.left).offset(-12)
            maker.top.equalTo(downloadRoot.snp.top)
            maker.bottom.equalTo(downloadRoot.snp.bottom)
        }
    }

    // MARK: Motion
    private var startX: CGFloat = -1
    private var startY: CGFloat = -1

    @objc
    private func onMotionEvent(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case UIGestureRecognizerState.began:
            Events.trackImagDetailBeginDrag()
            
            startX = mainImageView.center.x
            startY = mainImageView.center.y
            resetExtraInformationConstraint()
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

        switch downloadItem?.status {
        case DownloadStatus.Downloading.rawValue:
            DownloadManager.instance.cancel(id: bindImage.id!)
            break
        case DownloadStatus.Success.rawValue:
            Log.info(tag: ImageDetailView.self.description(), "click on success")
            delegate?.onRequestEdit(item: downloadItem!)
            break
        default:
            delegate?.onRequestImageDownload(image: bindImage)
            break
        }
    }

    @objc
    private func onClickAuthorName() {
        Events.trackClickAuthor()
        guard let url = bindImage?.userHomePage else {
            return
        }
        delegate?.onRequestOpenUrl(urlString: url)
    }

    @objc private func onClickBackground() {
        Events.trackImagDetailTapToDismiss()
        hideInternal()
    }

    private var downloadItem: DownloadItem? = nil

    // MARK: Bind
    private func bind() {
        guard let initFrame = initFrame,
              let image = bindImage else {
            return
        }

        disposable?.dispose()
        disposable = DownloadManager.instance.addObserver(image, { [weak self] (e) in
            guard let item = e.element else {
                return
            }
            guard let self = self else {
                return
            }

            if item.id != image.id {
                return
            }

            self.downloadItem = item

            Log.info(tag: ImageDetailView.self.description(), "download status: \(item.status)")

            self.downloadButton.updateStatus(item)
            self.updateProgressLayer()
        })

        mainImageView.frame = initFrame
        mainImageView.applyMask()
        
        if let listUrl = image.listUrl {
            ImageIO.loadImage(url: listUrl, intoView: mainImageView, fade: false)
        }

        let themeColor = image.themeColor
        let isThemeLight = themeColor.isLightColor()

        extraInformationView.backgroundColor = themeColor.mixBlackInDarkMode()

        photoByLabel.text = image.isUnsplash ? R.strings.author : R.strings.recommend_by

        let textColor = isThemeLight ? UIColor.black : UIColor.white
        let revertTextColor = isThemeLight ? UIColor.white : UIColor.black

        photoByLabel.textColor = textColor

        var attrs = [NSAttributedString.Key: Any]()
        attrs[NSAttributedString.Key.foregroundColor] = textColor
        attrs[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        let underlineAttributedString = NSAttributedString(string: image.userName!, attributes: attrs)
        authorButton.setAttributedTitle(underlineAttributedString, for: .normal)

        downloadButton.setTitleColor(revertTextColor, for: .normal)
        downloadRoot.backgroundColor = textColor.withAlphaComponent(0.4)
        shareButton.tintColor = textColor

        updateProgressLayer()
    }
    
    @objc
    private func onClickShare() {
        guard let item = bindImage else {
            return
        }

        UIApplication.shared.getTopViewController()?.presentShare(item, shareButton)
    }
    
    private func updateProgressLayer() {
        guard let image = self.bindImage else {
            return
        }
        
        guard let downloadItem = self.downloadItem else {
            return
        }
        
        let buttonWidth = downloadRoot.bounds.width
        let buttonHeight = downloadRoot.bounds.height

        var progress: Float
        
        switch downloadItem.status {
        case DownloadStatus.Downloading.rawValue:
            progress = downloadItem.progress
        default:
            progress = 1.0
        }
        
        if image.themeColor.isLightColor() {
            progressLayer.backgroundColor = UIColor.black.cgColor
        } else {
            progressLayer.backgroundColor = UIColor.white.cgColor
        }
                
        let layerWidth = Int(ceil(buttonWidth * CGFloat(progress)))
        progressLayer.frame = CGRect(x: 0, y: 0, width: layerWidth, height: Int(buttonHeight))
        
        Log.info(tag: "detailsview", "layer bounds is \(progressLayer.frame), progress: \(progress)")
    }

    private func resetExtraInformationConstraint() {
        extraInformationView.isHidden = true
        extraInformationView.snp.remakeConstraints { maker in
            maker.left.equalTo(mainImageView.snp.left)
            maker.right.equalTo(mainImageView.snp.right)
            maker.height.equalTo(Dimensions.ImageDetailExtraHeight)
            maker.bottom.equalTo(self.mainImageView.snp.bottom)
        }
    }
    
    func invalidate() {
        if self.isHidden {
            return
        }
        
        self.mainImageView.frame = self.finalFrame
        
        extraInformationView.snp.remakeConstraints { maker in
            maker.left.equalTo(mainImageView.snp.left)
            maker.right.equalTo(mainImageView.snp.right)
            maker.height.equalTo(Dimensions.ImageDetailExtraHeight)
            maker.top.equalTo(self.mainImageView.snp.bottom).offset(-1)
        }
    }

    private func showInternal() {
        Events.trackImagDetailShown()
        
        self.backgroundView.alpha = 0.0
        isHidden = false

        UIView.animate(withDuration: 0.3,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseInOut,
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
            maker.left.equalTo(mainImageView.snp.left)
            maker.right.equalTo(mainImageView.snp.right)
            maker.height.equalTo(Dimensions.ImageDetailExtraHeight)
            maker.top.equalTo(self.mainImageView.snp.bottom).offset(-1)
        }

        UIView.animate(withDuration: 0.4,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseInOut,
                animations: {
                    self.layoutIfNeeded()
                },
                completion: nil)
    }

    private func hideInternal() {
        disposable?.dispose()

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
            maker.left.equalTo(mainImageView.snp.left)
            maker.right.equalTo(mainImageView.snp.right)
            maker.height.equalTo(Dimensions.ImageDetailExtraHeight)
            maker.bottom.equalTo(self.mainImageView.snp.bottom)
        }

        UIView.animate(withDuration: Values.A_BIT_SLOW_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseInOut,
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
                options: UIView.AnimationOptions.curveEaseInOut,
                animations: {
                    self.backgroundView.alpha = 0.0
                    self.mainImageView.frame = self.initFrame!
                    
                    // Make sure the subview can layout according to the superview's frame changes
                    self.mainImageView.layoutIfNeeded()
                },
                completion: { b in
                    self.isHidden = true
                    self.extraInformationView.isHidden = true
                    self.delegate?.onHidden()
                })
    }
}
