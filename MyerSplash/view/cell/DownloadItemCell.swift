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
    
    static let BOTTOM_BUTTON_HEIGHT = 50
    
    private var image: UnsplashImage? = nil
    
    private var mainImageView: DayNightImageView!
    private var button: DownloadButton!
    
    var onClickEdit: ((UnsplashImage)->Void)? = nil
    var onClickDownload: ((UnsplashImage)->Void)? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        button = DownloadButton()
        button.contentHorizontalAlignment = .leading

        button.setTitleColor(.getDefaultBackgroundUIColor(), for: .normal)
        button.backgroundColor = .getDefaultLabelUIColor()
        button.addTarget(self, action: #selector(handleClickedSetAs), for: .touchUpInside)
        button.showsTouchWhenHighlighted = false
        button.layer.cornerRadius = 0
        
        mainImageView = DayNightImageView()
        mainImageView.clipsToBounds = true
        mainImageView.applyMask()
        
        self.contentView.addSubview(mainImageView)
        self.contentView.addSubview(button)
        
        button.snp.makeConstraints { (maker) in
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
        
    func bind(_ image: UnsplashImage) {
        guard let view = mainImageView else {
            return
        }
        
        self.image = image
        
        if let url = image.listUrl {
            ImageIO.loadImage(url: url, intoView: view)
        }
        
        button.backgroundColor = image.themeColor.getDarker(alpha: 0.7)
        
        let isLight = image.themeColor.isLightColor()
        
        if isLight {
            button.titleLabel?.textColor = .black
        } else {
            button.titleLabel?.textColor = .white
        }
        
        unbind()
        disposable = DownloadManager.instance.addObserver(image) { [weak self] (e) in
            guard let element = e.element else { return }
            guard let self = self else { return }

            if e.element?.id != image.id {
                return
            }
            
            self.downloadItem = element
            self.button.updateStatus(element)
        }
    }
    
    func unbind() {
        disposable?.dispose()
    }
    
    @objc
    private func handleClickedSetAs() {
        guard let image = self.image,
            let item = self.downloadItem else {
            return
        }
        
        switch item.status {
        case DownloadStatus.Downloading.rawValue:
            DownloadManager.instance.cancel(id: image.id!)
        case DownloadStatus.Failed.rawValue:
            onClickDownload?(image)
        case DownloadStatus.Success.rawValue:
            onClickEdit?(image)
        default:
            break
        }
    }
}
