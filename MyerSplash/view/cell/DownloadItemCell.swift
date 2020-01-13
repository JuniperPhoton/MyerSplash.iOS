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

class DownloadItemCell: UICollectionViewCell {
    static let ID = "DownloadItemCell"
    
    private static let TAG = "DownloadItemCell"

    static let BOTTOM_BUTTON_HEIGHT = 50

    private var image: UnsplashImage? = nil

    private var mainImageView: DayNightImageView!
    private var button: DownloadButton!
    private var downloadRoot: UIView!
    
    private var progressLayer: CALayer!

    var onClickEdit: ((UnsplashImage) -> Void)? = nil
    var onClickDownload: ((UnsplashImage) -> Void)? = nil
    var onDownloadItemUpdated: ((DownloadItem) -> Void)? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .black
        
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
        progressLayer.frame = CGRect(x: 0, y: 0, width: 10, height: DownloadItemCell.BOTTOM_BUTTON_HEIGHT)
        downloadRoot.layer.addSublayer(progressLayer)
        downloadRoot.layer.masksToBounds = true
        
        downloadRoot.addSubview(button)
        
        button.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }

        mainImageView = DayNightImageView()
        mainImageView.clipsToBounds = true
        mainImageView.applyMask()

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
    }

    func bind(_ image: UnsplashImage) {
        guard let view = mainImageView else {
            return
        }

        self.image = image

        if let url = image.listUrl {
            ImageIO.loadImage(url: url, intoView: view)
        }

        downloadRoot.backgroundColor = image.themeColor.getDarker(alpha: 0.7)
        updateProgressLayer()
        
        let isLight = image.themeColor.isLightColor()

        if isLight {
            button.setTitleColor(.black, for: .normal)
        } else {
            button.setTitleColor(.white, for: .normal)
        }

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
    }
    
    private func updateProgressLayer() {
        let cellWidth = downloadRoot.bounds.width
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
        progressLayer.frame = CGRect(x: 0, y: 0, width: layerWidth, height: DownloadItemCell.BOTTOM_BUTTON_HEIGHT)
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
