import Foundation
import UIKit
import SnapKit
import Nuke
import MaterialComponents.MaterialRipple
import MyerSplashShared

public class MainImageTableCell: UICollectionViewCell {
    static let ID = "MainImageTableCell"
    
    private var downloadRippleController: MDCRippleTouchController!
    
    // todo: use new code style
    private var downloadView: UIButton!
    private var todayTag: UIView!
    private var todayTextTag: UILabel!
    private var bindImage: UnsplashImage?
    
    private lazy var retryButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold))
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.isHidden = true
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(onClickRetry), for: .touchUpInside)
        return button
    }()

    var mainImageView: DayNightImageView!

    var onClickMainImage: ((CGRect, UnsplashImage, String) -> Void)?
    var onClickDownload: ((UnsplashImage) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainImageView = DayNightImageView()
        mainImageView.contentMode = UIView.ContentMode.scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                action: #selector(self.onClickImage)))

        let largeConfig = UIImage.SymbolConfiguration(pointSize: 23)
        let downloadImage = UIImage(systemName: "arrow.down", withConfiguration: largeConfig)?.withRenderingMode(.alwaysTemplate)
        downloadView = UIButton()
        downloadView.setImage(downloadImage, for: .normal)
        downloadView.adjustsImageWhenHighlighted = false
        downloadView.tintColor = UIColor.white
        downloadView.alpha = 0.7
        downloadView.addTarget(self, action: #selector(onClickDownloadButton), for: .touchUpInside)

        downloadRippleController = createRippleController(intoView: downloadView)

        todayTag = UIImageView(image: UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate))
        todayTag.isHidden = true
        todayTag.tintColor = UIColor.yellow

        todayTextTag = UILabel()
        todayTextTag.text = R.strings.today
        todayTextTag.textColor = UIColor.white
        todayTextTag.font = todayTextTag.font.with(traits: .traitBold).withSize(14)

        contentView.addSubview(mainImageView)
        contentView.addSubview(downloadView)
        contentView.addSubview(todayTag)
        contentView.addSubview(todayTextTag)
        contentView.addSubview(retryButton)

        mainImageView.snp.makeConstraints { (maker) in
            maker.left.equalTo(contentView.snp.left)
            maker.right.equalTo(contentView.snp.right)
            maker.top.equalTo(contentView.snp.top)
            maker.bottom.equalTo(contentView.snp.bottom)
        }

        downloadView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(56)
            maker.right.equalTo(contentView.snp.right)
            maker.bottom.equalTo(contentView.snp.bottom)
        }

        todayTag.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(23)
            maker.left.equalTo(contentView.snp.left).offset(15)
            maker.bottom.equalTo(contentView.snp.bottom).offset(-15)
        }

        todayTextTag.snp.makeConstraints { (maker) in
            maker.left.equalTo(todayTag.snp.right).offset(8)
            maker.centerY.equalTo(todayTag.snp.centerY).offset(2)
        }
        
        retryButton.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func createRippleController(intoView: UIView)-> MDCRippleTouchController {
        return MDCRippleTouchController.load(intoView: intoView,
                                             withColor: UIColor.white.withAlphaComponent(0.3), maxRadius: 30)
    }

    func bind(image: UnsplashImage) {
        bindImage = image
        mainImageView.backgroundColor = image.themeColor.getDarker(alpha: 0.7)

        todayTag.isHidden = !UnsplashImage.isToday(image)
        todayTextTag.isHidden = !UnsplashImage.isToday(image)
        
        mainImageView.applyMask()
        
        contentView.layer.cornerRadius = Dimensions.SmallRoundCornor.toCGFloat()
        contentView.layer.masksToBounds = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateLayer()
    }
    
    func loadImage(fade: Bool) {
        guard let url = bindImage?.listUrl else {
            return
        }
        
        let startTime = NetworkQuality.sharedInstance.getCurrentTimeMillis()
        
        ImageIO.shared.loadImage(url: url, intoView: mainImageView, fade: fade, completion: { [weak self] result in
            guard let self = self else { return }
            let response = try? result.get()
            self.retryButton.isHidden = response != nil
                        
            NetworkQuality.sharedInstance.recordDownloadDuration(startMillis: startTime, success: response != nil)
        })
    }

    private func cachedImageUrl() -> String? {
        guard let urls = bindImage?.urls else { return nil }
        let regularUrl = urls.regular
        
        if ImageIO.shared.isImageCached(regularUrl) {
            return regularUrl
        }
        
        let smallUrl = urls.small
        
        if ImageIO.shared.isImageCached(smallUrl) {
            return smallUrl
        }
        
        let thumbUrl = urls.thumb
        
        if ImageIO.shared.isImageCached(thumbUrl) {
            return thumbUrl
        }

        return nil
    }

    @objc
    private func onClickImage() {
        guard let bindImage = bindImage,
              let superView = superview else {
            print("bindImage is nil or superview is nil")
            return
        }
        
        guard let cachedUrl = cachedImageUrl() else {
            print("image not cached, skip showing details")
            return
        }

        let rect = superView.convert(frame, to: nil)
        onClickMainImage?(rect, bindImage, cachedUrl)
    }

    @objc
    private func onClickDownloadButton() {
        if let image = bindImage {
            onClickDownload?(image)
        }
    }
    
    @objc
    private func onClickRetry() {
        loadImage(fade: true)
        retryButton.isHidden = true
    }

    private func animateDownloadButton() {
        UIView.animateKeyframes(withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIView.KeyframeAnimationOptions(),
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                            relativeDuration: 0.5) {
                        self.downloadView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                    }
                    UIView.addKeyframe(withRelativeStartTime: Values.DEFAULT_ANIMATION_DURATION_SEC,
                            relativeDuration: 0.5) {
                        self.downloadView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }
                },
                completion: nil)
    }
}
