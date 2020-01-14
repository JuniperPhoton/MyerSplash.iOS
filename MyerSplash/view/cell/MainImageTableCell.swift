import Foundation
import UIKit
import SnapKit
import Nuke
import MaterialComponents.MaterialRipple

public class MainImageTableCell: UICollectionViewCell {
    static let ID = "MainImageTableCell"

    private var downloadView: UIButton!
    private var todayTag: UIView!
    private var todayTextTag: UILabel!
    private var bindImage: UnsplashImage?

    private var downloadRippleController: MDCRippleTouchController!

    var mainImageView: DayNightImageView!

    var onClickMainImage: ((CGRect, UnsplashImage) -> Void)?
    var onClickDownload: ((UnsplashImage) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainImageView = DayNightImageView()
        mainImageView.applyMask()
        mainImageView.contentMode = UIView.ContentMode.scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                action: #selector(self.onClickImage)))

        downloadView = UIButton()
        downloadView.setImage(UIImage(
            named: R.icons.ic_download)?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)),
                for: .normal)
        downloadView.adjustsImageWhenHighlighted = false
        downloadView.addTarget(self, action: #selector(clickDownloadButton), for: .touchUpInside)

        downloadRippleController = MDCRippleTouchController.load(
                intoView: downloadView, withColor: UIColor.white.withAlphaComponent(0.3), maxRadius: 30)

        todayTag = UIImageView(image: UIImage(named: R.icons.ic_star))
        todayTag.isHidden = true

        todayTextTag = UILabel()
        todayTextTag.text = R.strings.today
        todayTextTag.textColor = UIColor.white
        todayTextTag.font = todayTextTag.font.with(traits: .traitBold).withSize(14)

        contentView.addSubview(mainImageView)
        contentView.addSubview(downloadView)
        contentView.addSubview(todayTag)
        contentView.addSubview(todayTextTag)

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
            maker.top.equalTo(todayTag.snp.top)
            maker.bottom.equalTo(todayTag.snp.bottom)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(image: UnsplashImage) {
        bindImage = image
        mainImageView.backgroundColor = image.themeColor.getDarker(alpha: 0.7)

        todayTag.isHidden = !UnsplashImage.isToday(image)
        todayTextTag.isHidden = !UnsplashImage.isToday(image)
    }
    
    func loadImage(fade: Bool) {
        guard let url = bindImage?.listUrl else {
            return
        }
        ImageIO.loadImage(url: url, intoView: mainImageView, fade: fade)
    }

    private func isImageCached() -> Bool {
        guard let bindImage = bindImage,
              let url = bindImage.listUrl else {
            return false
        }
        return ImageIO.isImageCached(url)
    }

    @objc
    private func onClickImage() {
        guard let bindImage = bindImage,
              let superView = superview else {
            print("bindImage is nil or superview is nil")
            return
        }

        if (!isImageCached()) {
            print("image not cached, skip showing details")
            return
        }

        let rect = superView.convert(frame, to: nil)
        onClickMainImage?(rect, bindImage)
    }

    @objc
    private func clickDownloadButton() {
        if let image = bindImage {
            onClickDownload?(image)
        }
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
