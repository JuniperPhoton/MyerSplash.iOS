import Foundation
import UIKit
import SnapKit
import Nuke

public class MainImageTableCell: UITableViewCell {
    static let ID = "MainImageTableCell"

    private var downloadView: UIButton!

    private var bindImage: UnsplashImage?

    var mainImageView: UIImageView!

    var onClickMainImage: ((CGRect, UnsplashImage) -> Void)?
    var onClickDownload:  ((UnsplashImage) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)

        mainImageView = UIImageView()
        mainImageView.contentMode = UIView.ContentMode.scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(self.onClickImage)))

        downloadView = UIButton()
        downloadView.setImage(UIImage(named: "ic_file_download_white")?
                                      .resizableImage(withCapInsets: UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)), for: .normal)
        downloadView.addTarget(self, action: #selector(clickDownloadButton), for: .touchUpInside)

        contentView.addSubview(mainImageView)
        contentView.addSubview(downloadView)

        mainImageView.snp.makeConstraints { (maker) in
            maker.left.equalTo(contentView.snp.left)
            maker.right.equalTo(contentView.snp.right)
            maker.top.equalTo(contentView.snp.top)
            maker.bottom.equalTo(contentView.snp.bottom)
        }

        downloadView.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(40)
            maker.right.equalTo(contentView.snp.right).offset(-8)
            maker.bottom.equalTo(contentView.snp.bottom).offset(-8)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(image: UnsplashImage) {
        bindImage = image
        mainImageView.backgroundColor = image.themeColor.getDarker(alpha: 0.7)
        mainImageView.image = nil

        downloadView.isHidden = !AppSettings.isQuickDownloadEnabled()

        Nuke.loadImage(with: URL(string: image.listUrl!)!, into: mainImageView)
    }

    private func isImageCached() -> Bool {
        guard let bindImage = bindImage,
              let url = bindImage.listUrl else {
            return false
        }
        return ImageCache.isCached(urlString: url)
    }

    @objc
    private func onClickImage() {
        guard let bindImage = bindImage,
              let superView = superview else {
            return
        }

        if (!isImageCached()) {
            return
        }

        let rect = superView.convert(frame, to: nil)
        onClickMainImage?(rect, bindImage)
    }

    @objc
    private func clickDownloadButton() {
        if let image = bindImage {
            animateDownloadButton()
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
