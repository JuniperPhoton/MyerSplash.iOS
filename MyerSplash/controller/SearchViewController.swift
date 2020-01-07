//
//  SearchViewController.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/7.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MDCRippleTouchController
import FlexLayout

class SearchViewController: UIViewController {
    private var closeRippleController: MDCRippleTouchController!
    private var searchView: UISearchBar!
    
    private var listController: ImagesViewController? = nil
    
    private var searchHintView: SearchHintView!
    private var imageDetailView: ImageDetailView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = self.view else {
            return
        }
        
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear

            let blurEffect: UIBlurEffect!
            if #available(iOS 13.0, *) {
                blurEffect = UIBlurEffect(style: .systemChromeMaterial)
            } else {
                blurEffect = UIBlurEffect(style: .light)
            }
            let blurEffectView = UIVisualEffectView(effect: blurEffect)

            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            view.addSubview(blurEffectView)
        } else {
            view.backgroundColor = .getDefaultBackgroundUIColor()
        }
        
        searchView = UISearchBar()
        searchView.placeholder = "Search in English"
        searchView.searchBarStyle = .minimal
        searchView.delegate = self
        searchView.becomeFirstResponder()
        searchView.tintColor = UIColor.getDefaultLabelUIColor()
        searchView.searchTextField.keyboardType = .asciiCapable

        view.addSubview(searchView)
        
        let closeButton = UIButton()
        let closeImage = UIImage.init(named: "ic_clear_white")!.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        closeButton.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
//        let searchHintView = SearchHintView()
//        searchHintView.onClickKeyword = { [weak self] (keyword) in
//            self?.addImageViewController(keyword.query)
//        }
//        self.view.addSubview(searchHintView)
        
        closeRippleController = MDCRippleTouchController.load(intoView: closeButton,
                                                              withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3),
                                                              maxRadius: 25)
        
        closeButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(searchView.snp.top)
            maker.bottom.equalTo(searchView.snp.bottom)
            maker.right.equalToSuperview().offset(-10)
            maker.width.equalTo(50)
        }
        
        searchView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(12)
            maker.right.equalTo(closeButton.snp.left)
            maker.top.equalToSuperview().offset(UIView.topInset)
        }
        
//        searchHintView.snp.makeConstraints { (maker) in
//            maker.top.equalTo(searchView.snp.bottom)
//            maker.left.equalToSuperview()
//            maker.right.equalToSuperview()
//            maker.bottom.equalToSuperview()
//        }
        
        imageDetailView = ImageDetailView(frame: self.view.bounds)
        imageDetailView.delegate = self
    }
    
    @objc
    private func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addImageViewController(_ query: String) {
        listController?.delegate = nil
        listController?.remove()
        
        let controller = ImagesViewController(SearchImageRepo(query: query))
        controller.delegate = self
        self.add(controller)
        
        controller.view.snp.makeConstraints { (maker) in
            maker.top.equalTo(searchView.snp.bottom)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        self.listController = controller
        
        imageDetailView?.removeFromSuperview()
        self.view.addSubview(imageDetailView)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
        
        let query = searchBar.text ?? ""
        print("begin search: \(query)")
        
        if query == "" {
            return
        }
        
        addImageViewController(query)
    }
}

extension SearchViewController: ImageDetailViewDelegate, ImagesViewControllerDelegate {
    // MARK: ImageDetailViewDelegate
    func onHidden() {
        if let vc = self.listController {
            vc.showTappedCell()
        }
    }

    func onRequestOpenUrl(urlString: String) {
        UIApplication.shared.open(URL(string: urlString)!)
    }

    func onRequestImageDownload(image: UnsplashImage) {
        onRequestDownload(image: image)
    }
    
    // MARK: ImagesViewControllerDelegate
    func onClickImage(rect: CGRect, image: UnsplashImage)-> Bool {
        imageDetailView?.show(initFrame: rect, image: image)
        return true
    }

    func onRequestDownload(image: UnsplashImage) {
        DownloadManager.prepareToDownload(vc: self, image: image) { [weak self] (imagePath) in
            guard let self = self else {
                return
            }
            UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: imagePath)!, self, #selector(self.onSavedOrError), nil)
        }
    }
    
    @objc
    private func onSavedOrError(_ image: UIImage,
                                didFinishSavingWithError error: Error?,
                                contextInfo: UnsafeRawPointer) {
        DownloadManager.showSavedToastOnVC(self, success: error == nil)
    }
}
