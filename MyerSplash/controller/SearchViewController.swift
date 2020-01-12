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
import RxSwift

class SearchViewController: UIViewController {
    private var closeRippleController: MDCRippleTouchController!
    private var searchView: UISearchBar!

    private var listController: ImagesViewController? = nil

    private var searchHintView: SearchHintView!
    private var imageDetailView: ImageDetailView!

    private var disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view else {
            return
        }

        let blurEffectView = UIView.makeBlurBackgroundView()
        if let blurView = blurEffectView {
            view.backgroundColor = .clear
            blurView.frame = view.bounds
            view.addSubview(blurView)
        } else {
            view.backgroundColor = .getDefaultBackgroundUIColor()
        }

        searchView = UISearchBar()
        searchView.placeholder = R.strings.search_hint
        searchView.searchBarStyle = .minimal
        searchView.delegate = self
        searchView.becomeFirstResponder()
        searchView.tintColor = UIColor.getDefaultLabelUIColor()
        searchView.searchTextField.keyboardType = .asciiCapable
        searchView.searchTextField.font = searchView.searchTextField.font?.withSize(16)

        view.addSubview(searchView)

        let closeButton = UIButton()
        let closeImage = UIImage(named: R.icons.ic_clear)!.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        closeButton.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        self.view.addSubview(closeButton)

        searchHintView = SearchHintView()
        searchHintView.onClickKeyword = { [weak self] (keyword) in
            self?.searchView.text = keyword.query
            self?.addImageViewController(keyword.query)
            self?.searchView.resignFirstResponder()
        }
        searchHintView.isUserInteractionEnabled = true
        self.view.addSubview(searchHintView)

        let rippleColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3)
        closeRippleController = MDCRippleTouchController.load(intoView: closeButton,
                withColor: rippleColor, maxRadius: 25)

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

        searchHintView.snp.makeConstraints { (maker) in
            maker.top.equalTo(searchView.snp.bottom)
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }

        imageDetailView = ImageDetailView(frame: self.view.bounds)
        imageDetailView.delegate = self
    }

    @objc
    private func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }

    private func addImageViewController(_ query: String) {
        searchHintView.isHidden = true

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

    func onRequestEdit(item: DownloadItem) {
        presentEdit(item: item)
    }

    func onRequestOpenUrl(urlString: String) {
        UIApplication.shared.open(URL(string: urlString)!)
    }

    func onRequestImageDownload(image: UnsplashImage) {
        onRequestDownload(image: image)
    }

    // MARK: ImagesViewControllerDelegate
    func onClickImage(rect: CGRect, image: UnsplashImage) -> Bool {
        imageDetailView?.show(initFrame: rect, image: image)
        return true
    }

    override func viewDidDisappear(_ animated: Bool) {
        // todo
    }

    func onRequestDownload(image: UnsplashImage) {
        DownloadManager.instance.prepareToDownload(vc: self, image: image)
    }
}
