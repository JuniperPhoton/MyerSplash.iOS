//
//  DownloadItemCell.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/8.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import MyerSplashShared

class DownloadItemCell: UICollectionViewCell {
    static let ID = "DownloadItemCell"
    
    private static let TAG = "DownloadItemCell"

    static let BOTTOM_BUTTON_HEIGHT = 50

    private var image: UnsplashImage? = nil

    private var mainImageView: DayNightImageView!
    private var button: DownloadButton!
    private var downloadRoot: UIView!
    
    private(set) lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: R.icons.ic_share), for: .normal)
        button.alpha = 0.3
        button.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
        return button
    }()
    
    private var progressLayer: CALayer!

    var onClickEdit: ((UnsplashImage) -> Void)? = nil
    var onClickDownload: ((UnsplashImage) -> Void)? = nil
    var onDownloadItemUpdated: ((DownloadItem) -> Void)? = nil
    var onClickShare: ((UnsplashImage) -> Void)? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
                
        downloadRoot = UIView()
        downloadRoot.backgroundColor = .getDefaultLabelUIColor()

        button = DownloadButton()
        button.contentHorizontalAlignment = .leading

        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleClickedSetAs), for: .touchUpInside)
        button.showsTouchWhenHighlighted = false
        button.layer.cornerRadius = 0
        
        progressLayer = CALayer()
        progressLayer.needsDisplayOnBoundsChange = true
        progressLayer.frame = CGRect(x: 0, y: 0, width: 0, height: DownloadItemCell.BOTTOM_BUTTON_HEIGHT)
        downloadRoot.layer.addSublayer(progressLayer)
        downloadRoot.layer.masksToBounds = true
        
        downloadRoot.addSubview(button)
        downloadRoot.addSubview(shareButton)
        
        button.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        shareButton.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview()
            maker.top.bottom.equalToSuperview()
            maker.width.equalTo(shareButton.snp.height)
        }

        mainImageView = DayNightImageView()
        mainImageView.clipsToBounds = true

        self.contentView.addSubview(mainImageView)
        self.contentView.addSubview(downloadRoot)

        downloadRoot.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.height.equalTo(DownloadItemCell.BOTTOM_BUTTON_HEIGHT)
        }

        mainImageView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalTo(button.snp.top)
        }
    }

    deinit {
        unbind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var disposable: Disposable? = nil
    private var downloadItem: DownloadItem? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateLayer()
        updateProgressLayer()
    }
    
    @objc
    private func shareImage() {
        guard let image = self.image else {
            return
        }
        onClickShare?(image)
    }

    func bind(_ image: UnsplashImage) {
        guard let view = mainImageView else {
            return
        }

        self.image = image

        if let url = image.listUrl {
            ImageIO.shared.loadImage(url: url, intoView: view)
        }

        mainImageView.backgroundColor = image.themeColor.getDarker(alpha: 0.7)
        downloadRoot.backgroundColor = image.themeColor.getDarker(alpha: 0.7)

        mainImageView.applyMask()

        updateProgressLayer()
        
        let isLight = image.themeColor.isLightColor()

        let contentColor = isLight ? UIColor.black : UIColor.white
        
        button.setTitleColor(contentColor, for: .normal)
        shareButton.tintColor = contentColor

        unbind()
        disposable = DownloadManager.instance.addObserver(image) { [weak self] (e) in
            guard let element = e.element else {
                return
            }
            guard let self = self else {
                return
            }

            if e.element?.id != image.id {
                return
            }

            self.downloadItem = element
            self.button.updateStatus(element)
            self.updateProgressLayer()
            
            self.onDownloadItemUpdated?(element)
        }
        
        contentView.layer.cornerRadius = Dimensions.SmallRoundCornor.toCGFloat()
        contentView.layer.masksToBounds = true
    }
    
    private func updateProgressLayer() {
        let cellWidth = self.bounds.width
        var progress: Float
        
        if let downloadItem = self.downloadItem {
            switch downloadItem.status {
            case DownloadStatus.Downloading.rawValue:
                progress = downloadItem.progress
            default:
                progress = 1.0
            }
            
            progressLayer.backgroundColor = downloadItem.unsplashImage!.themeColor.mixBlackInDarkMode().cgColor
        } else {
            progress = 0.0
        }
        
        let layerWidth = Int(ceil(cellWidth * CGFloat(progress)))
        
        let targetFrame = CGRect(x: 0, y: 0, width: layerWidth, height: DownloadItemCell.BOTTOM_BUTTON_HEIGHT)
        
        // First init, skip animation
        if progressLayer.frame.width == 0 && progress == 1 {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.frame = targetFrame
            CATransaction.commit()
        } else {
            progressLayer.frame = targetFrame
        }
    }

    func unbind() {
        disposable?.dispose()
    }

    @objc
    private func handleClickedSetAs() {
        guard let image = self.image,
              let item = self.downloadItem else {
            Log.error(tag: DownloadItemCell.TAG, "image or download item is null")
            return
        }

        switch item.status {
        case DownloadStatus.Downloading.rawValue:
            DownloadManager.instance.cancel(id: image.id!)
        case DownloadStatus.Pending.rawValue:
            Log.error(tag: DownloadItemCell.TAG, "fallthrough pending status")
            fallthrough
        case DownloadStatus.Failed.rawValue:
            onClickDownload?(image)
        case DownloadStatus.Success.rawValue:
            onClickEdit?(image)
        default:
            break
        }
    }
}
