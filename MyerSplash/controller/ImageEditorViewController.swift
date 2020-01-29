//
//  ImageEditorViewController.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/9.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents
import Nuke
import RxSwift
import func AVFoundation.AVMakeRect

class ImageEditorViewController: UIViewController {
    private static let TAG = "ImageEditViewController"
    private static let MAX_DIM_VALUE = 0.7

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }

    private var image: UnsplashImage!
    private var item: DownloadItem!

    private var loadingIndicator: MDCActivityIndicator!
    private var exposureSlider: MDCSlider!

    private var imageView: UIImageView!
    private var maskView: UIView!
    private var homePreviewView: UIImageView!
    private var scrollView: UIScrollView!
    
    private var composeFab: MDCFloatingButton = {
        let composeFab = MDCFloatingButton()
        let doneImage = UIImage(named: R.icons.ic_save)?.withRenderingMode(.alwaysTemplate)
        composeFab.setImage(doneImage, for: .normal)
        composeFab.tintColor = .white
        composeFab.backgroundColor = Colors.THEME.asUIColor()
        composeFab.addTarget(self, action: #selector(onClickCompose), for: .touchUpInside)
        return composeFab
    }()
    
    private var homeFab: MDCFloatingButton = {
        let homeFab = MDCFloatingButton()
        let homeImage = UIImage(named: R.icons.ic_home)?.withRenderingMode(.alwaysTemplate)
        homeFab.setImage(homeImage, for: .normal)
        homeFab.tintColor = UIColor.black
        homeFab.backgroundColor = UIColor.white
        homeFab.addTarget(self, action: #selector(onClickHome), for: .touchUpInside)
        return homeFab
    }()
    
    private var composeIndicator: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.sizeToFit()
        indicator.cycleColors = [UIColor.white]
        indicator.startAnimating()
        indicator.isHidden = true
        return indicator
    }()

    init(item: DownloadItem) {
        self.item = item
        self.image = item.unsplashImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black
        
        Events.trackEdit()

        scrollView = UIScrollView()
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        scrollView.addSubview(imageView)

        self.view.addSubview(scrollView)

        scrollView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }

        // MARK: MASK
        maskView = UIView()
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.view.addSubview(maskView)
        maskView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        maskView.isUserInteractionEnabled = false

        let closeButton = MDCFloatingButton()
        self.view.addSubview(closeButton)

        // MARK: HOME SCREEN
        let homeIcon = UIImage(named: R.icons.ic_launcher)
        homePreviewView = UIImageView(image: homeIcon)
        homePreviewView.contentMode = .scaleAspectFit
        homePreviewView.isHidden = true
        homePreviewView.clipsToBounds = true
        self.view.addSubview(homePreviewView)
        homePreviewView.snp.makeConstraints { (maker) in
            maker.top.equalTo(closeButton.snp.bottom).offset(12)
            maker.left.right.equalToSuperview().inset(24)
            maker.aspectRatioByWidth(1003.0, by: 1464.0, self: homePreviewView)
        }

        // MARK: CLOSE BUTTON

        let closeImage = UIImage(named: R.icons.ic_clear)!.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .black
        closeButton.setShadowColor(UIColor.black.withAlphaComponent(0.3), for: .normal)
        closeButton.setBackgroundColor(.white)
        closeButton.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)

        closeButton.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(UIView.topInset + 12)
            maker.right.equalToSuperview().offset(-12)
            maker.width.equalTo(35)
            maker.height.equalTo(35)
        }

        // MARK: INDICATOR
        loadingIndicator = MDCActivityIndicator()
        loadingIndicator.sizeToFit()
        loadingIndicator.cycleColors = [UIColor.white]
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)

        loadingIndicator.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
        }

        // MARK: PANEL
        let editPanel = UIView()

        let blurEffect: UIBlurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        editPanel.addSubview(blurEffectView)

        self.view.addSubview(editPanel)

        editPanel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.height.equalTo(100)
        }

        // MARK: EXPOSURE ICON
        let exposureIcon = UIImage(named: R.icons.ic_exposure)!.withRenderingMode(.alwaysTemplate)
        let exposureImageView = UIImageView(image: exposureIcon)
        exposureImageView.tintColor = .white
        exposureImageView.contentMode = .scaleAspectFit

        editPanel.addSubview(exposureImageView)

        // MARK: SLIDER
        exposureSlider = MDCSlider()
        exposureSlider.addTarget(self, action: #selector(didChangeSliderValue), for: .valueChanged)
        exposureSlider.isStatefulAPIEnabled = true
        exposureSlider.setTrackBackgroundColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        exposureSlider.setThumbColor(.white, for: .normal)
        exposureSlider.setTrackFillColor(.white, for: .normal)
        editPanel.addSubview(exposureSlider)

        exposureImageView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(12)
            maker.width.equalTo(40)
            maker.bottom.equalToSuperview().offset(-40)
        }

        exposureSlider.snp.makeConstraints { (maker) in
            maker.left.equalTo(exposureImageView.snp.right)
            maker.right.equalToSuperview().offset(-12)
            maker.bottom.equalToSuperview().offset(-40)
        }

        // MARK: COMPOSE FAB
        self.view.addSubview(composeFab)

        composeFab.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.view).offset(-16)
            maker.bottom.equalTo(editPanel.snp.top).offset(25)
            maker.width.equalTo(50)
            maker.height.equalTo(50)
        }
        
        // MARK: COMPOSE INDICATOR
        self.view.addSubview(composeIndicator)
        composeIndicator.snp.makeConstraints { (maker) in
            maker.edges.equalTo(composeFab)
        }

        // MARK: HOME FAB
        self.view.addSubview(homeFab)
        
        if UIDevice.current.userInterfaceIdiom != .phone {
            homeFab.isHidden = true
        }

        homeFab.snp.makeConstraints { (maker) in
            maker.right.equalTo(composeFab.snp.left).offset(-14)
            maker.bottom.equalTo(editPanel.snp.top).offset(20)
            maker.width.equalTo(40)
            maker.height.equalTo(40)
        }

        loadImage(item: item)
    }

    @objc
    private func onClickCompose() {
        Events.trackEditOk()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.composeIndicator.isHidden = true
            self.toggleComposeFabIcon(true)
        }

        composeIndicator.isHidden = false
        composeIndicator.startAnimating()
        toggleComposeFabIcon(false)

        DispatchQueue.global().async {
            self.compose()
        }
    }
    
    private func toggleComposeFabIcon(_ show: Bool) {
        if show {
            let doneImage = UIImage(named: R.icons.ic_save)?.withRenderingMode(.alwaysTemplate)
            composeFab.setImage(doneImage, for: .normal)
        } else {
            composeFab.setImage(nil, for: .normal)
        }
    }

    private func compose() {
        guard let relativePath = item.fileURL else {
            return
        }
        
        let url = DownloadManager.instance.createAbsolutePathForImage(relativePath)

        guard let image = UIImage(contentsOfFile: url.path) else {
            Log.warn(tag: ImageEditorViewController.TAG, "error on getting cached file")
            return
        }

        guard let ciImage = CIImage(image: image) else {
            Log.warn(tag: ImageEditorViewController.TAG, "error on getting ci image")
            return
        }


        let actualDimValue = Float(ImageEditorViewController.MAX_DIM_VALUE) * Float(exposureSlider.value)

        let foregroundCiColor = CIColor(color: UIColor.black.withAlphaComponent(CGFloat(actualDimValue)))
        let foregroundMask = CIImage(color: foregroundCiColor)

        let context = CIContext()
        
        if let currentFilter = CIFilter(name: "CISourceOverCompositing") {
            currentFilter.setValue(foregroundMask, forKey: kCIInputImageKey)
            currentFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)

            if let output = currentFilter.outputImage {
                if let cgImage = context.createCGImage(output, from: ciImage.extent) {
                    let processedImage = UIImage(cgImage: cgImage)
                    Log.info(tag: ImageEditorViewController.TAG, "success on compose")

                    DispatchQueue.main.async {
                        UIImageWriteToSavedPhotosAlbum(processedImage, self, #selector(self.onSavedOrError), nil)
                    }
                } else {
                    Log.warn(tag: ImageEditorViewController.TAG, "error on context.createCGImage")
                }
            } else {
                Log.warn(tag: ImageEditorViewController.TAG, "error on currentFilter.outputImage")
            }
        }
    }

    @objc
    private func onSavedOrError(_ image: UIImage,
                                didFinishSavingWithError error: Error?,
                                contextInfo: UnsafeRawPointer) {
        if error == nil {
            self.view.showToast(R.strings.saved_album)
        } else {
            self.view.showToast(R.strings.failed_process)
        }
    }

    @objc
    private func onClickHome() {
        homePreviewView.isHidden = !homePreviewView.isHidden
    }

    @objc
    private func didChangeSliderValue(senderSlider: MDCSlider) {
        Log.info(tag: "slider", "value is \(senderSlider.value)")
        let actualDimValue = Float(ImageEditorViewController.MAX_DIM_VALUE) * Float(senderSlider.value)
        maskView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(actualDimValue))
    }

    private func loadImage(item: DownloadItem) {
        if let relativePath = item.fileURL {
            Log.info(tag: ImageEditorViewController.TAG, "about to load image of \(relativePath)")
            
            let screenBounds = UIScreen.main.bounds
            
            var width = item.unsplashImage!.width
            if width == 0 {
                width = 3
            }
            
            var height = item.unsplashImage!.height
            if height == 0 {
                height = 2
            }
            
            let imageRatio = CGFloat(width) / CGFloat(height)
            let screenRatio = CGFloat(screenBounds.width) / CGFloat(screenBounds.height)
            
            var targetWidth = 0
            var targetHeight = 0
            
            targetHeight = Int(max(screenBounds.height * (screenRatio) / imageRatio, screenBounds.height))
            targetWidth = Int(targetHeight.toCGFloat() * imageRatio)
            
            scrollView.contentSize = CGSize(width: targetWidth, height: targetHeight)
            
            imageView.snp.makeConstraints { (maker) in
                if targetWidth.toCGFloat() == screenBounds.width {
                    maker.width.equalToSuperview()
                } else if targetHeight.toCGFloat() == screenBounds.height {
                    maker.height.equalToSuperview()
                }
            }
            
            if targetWidth > Int(screenBounds.width) {
                let point = CGPoint(x: Int((targetWidth.toCGFloat() - screenBounds.width) / 2), y: 0)
                scrollView.setContentOffset(point, animated: false)
            }
            
            if targetHeight > Int(screenBounds.height) {
                let point = CGPoint(x: 0, y: Int((targetHeight.toCGFloat() - screenBounds.height) / 2))
                scrollView.setContentOffset(point, animated: false)
            }
                        
            Log.info(tag: ImageEditorViewController.TAG, "target w: \(targetWidth), target h: \(targetHeight)")
            
            let url = DownloadManager.instance.createAbsolutePathForImage(relativePath)
            
            DispatchQueue.global().async {
                let resizedImage = ImageIO.resizedImage(at: url, for: CGSize(width: targetWidth, height: targetHeight))
                
                DispatchQueue.main.async {
                    self.loadingIndicator.isHidden = true
                    self.loadImage(resizedImage)
                }
            }
        } else {
            loadImage(nil)
        }
    }
    
    private func loadImage(_ uiImage: UIImage?) {
        if uiImage == nil {
            showToast(R.strings.failed_to_load)
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.image = uiImage
    }

    @objc
    private func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }
}
