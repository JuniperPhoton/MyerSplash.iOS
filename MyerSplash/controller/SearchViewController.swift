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
import MyerSplashShared

class SearchViewController: UIViewController {
    private var closeRippleController: MDCRippleTouchController!
    
    private var listController: ImagesViewController? = nil
    
    private var imageDetailView: ImageDetailView!
    
    private var disposeBag = DisposeBag()
    
    private lazy var searchView: UISearchBar = {
        let searchView = UISearchBar()
        searchView.placeholder = R.strings.search_hint
        searchView.searchBarStyle = .minimal
        searchView.delegate = self
        searchView.tintColor = UIColor.getDefaultLabelUIColor()
        searchView.keyboardType = .asciiCapable
        searchView.becomeFirstResponder()
        searchView.textField?.font = searchView.textField?.font?.withSize(16)
        return searchView
    }()
    
    private lazy var closeButton: UIView = {
        let closeButton = UIButton()
        let closeImage = UIImage(named: R.icons.ic_clear)!.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        closeButton.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        return closeButton
    }()
    
    private lazy var searchHintView: UIView = {
        let searchHintView = SearchHintView()
        searchHintView.onClickKeyword = { [weak self] (keyword) in
            self?.searchView.text = keyword.query
            self?.addImageViewController(keyword.query)
            self?.searchView.resignFirstResponder()
        }
        searchHintView.isUserInteractionEnabled = true
        return searchHintView
    }()
    
    private lazy var blurEffectView: UIView = {
        let blurEffect: UIBlurEffect!
        if #available(iOS 13.0, *) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                blurEffect = UIBlurEffect(style: .systemThickMaterial)
            } else {
                blurEffect = UIBlurEffect(style: .systemMaterial)
            }
        } else {
            blurEffect = UIBlurEffect(style: .extraLight)
        }
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
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
        
        view.backgroundColor = .clear
        view.addSubViews(blurEffectView, searchView, closeButton, searchHintView)
        
        let rippleColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3)
        closeRippleController = MDCRippleTouchController.load(intoView: closeButton,
                                                              withColor: rippleColor, maxRadius: 25)
        imageDetailView = ImageDetailView(frame: self.view.bounds)
        imageDetailView.delegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        listController?.viewWillTransition(to: size, with: coordinator)
        imageDetailView.invalidate(newBounds: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let windowWidth = UIApplication.shared.windows[0].bounds.width
        
        #if targetEnvironment(macCatalyst)
        let topInset = 30.cgFloat
        #else
        let topInset = UIView.topInset
        #endif
        
        blurEffectView.pin.all()
        
        if UIDevice.current.userInterfaceIdiom == .pad && windowWidth > Dimensions.MIN_MODE_WIDTH {
            searchView.pin.width(Dimensions.MIN_MODE_WIDTH).top(topInset).hCenter().sizeToFit(.width)
            closeButton.pin.after(of: searchView, aligned: .center).size(50)
        } else {
            closeButton.pin.topRight().size(50).marginTop(UIView.topInset).marginRight(12)
            searchView.pin.left(12).before(of: closeButton, aligned: .center).top(topInset).sizeToFit(.width)
        }
        
        searchHintView.pin.below(of: searchView).left().right().bottom()
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
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.resignFirstResponder()
        } else {
            // Fallback on earlier versions
        }
        
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
    func onHidden(frameAnimationSkipped: Bool) {
        if let vc = self.listController {
            vc.showTappedCell(withAlphaAnimation: frameAnimationSkipped)
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

extension UISearchBar {
    var textField : UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            // Fallback on earlier versions
            for view : UIView in (self.subviews[0]).subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}
