//
//  ImagesViewController.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/5.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import MaterialComponents.MaterialActivityIndicator
import ELWaterFallLayout

protocol ImagesViewControllerDelegate: class {
    func onClickImage(rect: CGRect, image: UnsplashImage) -> Bool
    func onRequestDownload(image: UnsplashImage)
}

class ImagesViewController: UIViewController {
    static let TAG = "ImagesViewController"
    static let CELL_ANIMATE_OFFSET_X: CGFloat = 50.0
    static let CELL_ANIMATE_DELAY_UNIT_SEC = 0.1
    static let CELL_ANIMATE_DURATION_SEC = 0.4
    
    static let FOOTER_HEIGHT = 100
    
    static let HIGHLIGHTS_DELAY_SEC = 0.2
    
    private let waterfallLayout = ELWaterFlowLayout()
    
    private var paging = 1
    private var loading = false
    private var canLoadMore = false
    
    private var calculatedCellHeight: CGFloat = -1.0
    private var initialMaxVisibleCellCount = -1
    
    private var tappedCell: UICollectionViewCell? = nil
    
    private var startY: CGFloat = -1
    
    private var collectionView: UICollectionView!
    private var refreshControl: UIRefreshControl!
    
    private var errorHintView: ErrorHintView!
    
    private var imageRepo: ImageRepo? = nil
    
    private var indicator: MDCActivityIndicator!
    private var noItemView: UIView!
    private var loadingFooterView: MDCActivityIndicator!
    private var animateCellFinished = false
    
    var collectionTopOffset: CGFloat = 0
    
    weak var delegate: ImagesViewControllerDelegate? = nil
    
    var repoTitle: String? {
        get {
            return imageRepo?.title
        }
    }
    
    init(_ repo: ImageRepo) {
        self.imageRepo = repo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        let view = self.view!
        
        imageRepo?.onLoadFinished = { [weak self] (_ success: Bool, _ page: Int) in
            if let self = self {
                if !success {
                    showToast(R.strings.something_wrong)
                }
                
                self.indicator.stopAnimating()
                self.loading = false
                self.canLoadMore = !self.imageRepo!.images.isEmpty
                self.loadingFooterView.stopAnimating()
                self.stopRefresh()
                
                if page == 1 {
                    self.calculateInitialMaxVisibleCellCount()
                }
                
                if self.imageRepo!.images.isEmpty {
                    self.updateHintViews(success)
                }
                
                self.collectionView.reloadData()
            }
        }
        
        refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.addTarget(self, action: #selector(onRefreshData), for: .valueChanged)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: waterfallLayout)
        collectionView.backgroundColor = .clear
        collectionView.refreshControl = refreshControl
        
        view.addSubview(collectionView)
        
        waterfallLayout.delegate = self
        waterfallLayout.scrollDirection = .vertical
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            #if targetEnvironment(macCatalyst)
            print("run for macCatalyst")
            waterfallLayout.lineCount = UInt(calculateSpanCount(view.frame.width))
            #else
            print("run for pad")
            waterfallLayout.lineCount = 3
            #endif
            
            waterfallLayout.vItemSpace = 12
            waterfallLayout.hItemSpace = 12
            waterfallLayout.edge = UIEdgeInsets.init(top: 0, left: 12, bottom: 0, right: 12)
        } else {
            print("run for phone")
            waterfallLayout.lineCount = 1
            waterfallLayout.vItemSpace = 0
            waterfallLayout.hItemSpace = 0
        }
        
        collectionView.snp.makeConstraints { (maker) in
            maker.height.equalTo(view)
            maker.width.equalTo(view)
            maker.top.equalTo(view)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: collectionTopOffset, left: 0, bottom: 100, right: 0)
        collectionView.register(MainImageTableCell.self, forCellWithReuseIdentifier: MainImageTableCell.ID)
        
        loadingFooterView = MDCActivityIndicator()
        loadingFooterView.cycleColors = [.getDefaultLabelUIColor()]
        
        collectionView.addSubview(loadingFooterView)
        
        indicator = MDCActivityIndicator()
        indicator.sizeToFit()
        indicator.cycleColors = [UIColor.getDefaultLabelUIColor()]
        view.addSubview(indicator)
        
        errorHintView = ErrorHintView()
        errorHintView.onClickRetry = { [weak self] in
            self?.refreshData()
        }
        errorHintView.isHidden = true
        
        view.addSubview(errorHintView)
        
        errorHintView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        indicator.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
        }
        
        let noItemView = UILabel()
        noItemView.isHidden = true
        noItemView.text = R.strings.no_items
        noItemView.textColor = .getDefaultLabelUIColor()
        noItemView.font = noItemView.font.with(traits: .traitBold).withSize(32)
        self.view.addSubview(noItemView)
        self.noItemView = noItemView
        
        noItemView.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
        }
        
        refreshData()
    }
    
    private func calculateSpanCount(_ width: CGFloat)-> uint {
        let newSpan: uint
        switch width {
        case 0..<1000:
            newSpan = 2
        case 1000..<1600:
            newSpan = 3
        case 1600..<2200:
            newSpan = 4
        default:
            newSpan = 5
        }
        
        return newSpan
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if collectionView?.superview == nil {
            return
        }
        let currentSpan = waterfallLayout.lineCount
        let newSpan = calculateSpanCount(size.width)
        
        if newSpan != currentSpan {
            waterfallLayout.lineCount = UInt(newSpan)
            collectionView.setNeedsLayout()
        }
    }
    
    private func updateHintViews(_ success: Bool) {
        if !success {
            self.errorHintView.isHidden = false
        } else {
            self.noItemView.isHidden = false
        }
    }
    
    private func customRefreshControl() {
        refreshControl.tintColor = .clear
        
        let refreshIndicator = MDCActivityIndicator()
        refreshIndicator.startAnimating()
        refreshIndicator.cycleColors = [UIColor.getDefaultLabelUIColor()]
        
        refreshControl.addSubview(refreshIndicator)
        
        refreshIndicator.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
    
    func showTappedCell() {
        tappedCell?.isHidden = false
    }
    
    @objc
    private func refreshData() {
        print("refresh data")
        
        errorHintView.isHidden = true
        noItemView.isHidden = true
        
        paging = 1
        loadData(true)
    }
    
    private func loadData(_ refresh: Bool) {
        if (loading) {
            Log.warn(tag: ImagesViewController.TAG, "loading already, skip loading data")
            return
        }
        loading = true
        
        if imageRepo?.images.isEmpty ?? true && refresh {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
        
        imageRepo?.loadImage(paging)
    }
    
    private func loadMore() {
        if (!canLoadMore) {
            return
        }
        
        paging = paging + 1
        loadData(false)
    }
    
    func stopRefresh() {
        refreshControl.endRefreshing()
    }
    
    @objc
    private func onRefreshData() {
        print("onRefreshData")
        
        Events.trackRefresh(name: self.repoTitle ?? "")
        
        self.refreshData()
        
        if (refreshControl.isRefreshing) {
            refreshControl.endRefreshing()
        }
    }
    
    private func calculateInitialMaxVisibleCellCount() {
        guard let tableView = collectionView,
            let repo = imageRepo else {
                initialMaxVisibleCellCount = -1
                return
        }
        
        let tableViewFrame = tableView.frame
        let visibleHeight = tableViewFrame.height + tableView.contentOffset.y
        let visibleWidth = tableViewFrame.width
        
        var accHeight = CGFloat(0)
        
        for index in 0..<repo.images.count {
            let image = repo.images[index]
            let ratio = image.getAspectRatioF(viewWidth: tableView.bounds.width, viewHeight: tableView.bounds.height)
            accHeight += visibleWidth / ratio
            
            if (accHeight >= visibleHeight) {
                initialMaxVisibleCellCount = index + 1
                break
            }
        }
        
        print("initialMaxVisibleCellCount is ", initialMaxVisibleCellCount)
    }
    
    private func calculateCellHeight(_ index: Int) -> CGFloat {
        guard let image = imageRepo?.images[index] else {
            return 3 / 2.0
        }
        
        let space = waterfallLayout.hItemSpace * CGFloat(waterfallLayout.lineCount - 1) + waterfallLayout.edge.left + waterfallLayout.edge.right
        let width = CGFloat(collectionView.bounds.width) / CGFloat(waterfallLayout.lineCount) - space
        
        let ratio = image.getAspectRatioF(viewWidth: collectionView.bounds.width, viewHeight: collectionView.bounds.height)
        let height = width / ratio
        return floor(height)
    }
    
    // MARK: scroll
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We don't want the over-scrolling takes any showing & hiding effect.
        if (scrollView.contentOffset.y <= 0) {
            return
        }
        
        if (scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height) {
            loadMore()
        }
        
        if (scrollView.contentSize.height > scrollView.frame.size.height) {
            let frame = CGRect(x: 0,
                               y: scrollView.contentSize.height,
                               width: collectionView.frame.size.width,
                               height: ImagesViewController.FOOTER_HEIGHT.toCGFloat());
            self.loadingFooterView.frame = frame;
            self.loadingFooterView.startAnimating()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y <= 0) {
            //print("prepare to showNavigationElements")
        }
    }
}

extension ImagesViewController: ELWaterFlowLayoutDelegate {
    func el_flowLayout(_ flowLayout: ELWaterFlowLayout, heightForRowAt index: Int) -> CGFloat {
        return calculateCellHeight(index)
    }
}

extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageRepo!.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MainImageTableCell.ID, for: indexPath) as? MainImageTableCell else {
                fatalError()
        }
        
        cell.onClickDownload = { [weak self] unsplashImage in
            self?.delegate?.onRequestDownload(image: unsplashImage)
        }
        cell.onClickMainImage = { [weak self] (rect: CGRect, image: UnsplashImage) -> Void in
            if self?.delegate?.onClickImage(rect: rect, image: image) == true {
                cell.isHidden = true
                self?.tappedCell = cell
            }
        }
        
        let image = self.imageRepo!.images[indexPath.row]
        
        cell.bind(image: image)
        
        if !willCellPerformEnterAnimation(indexPath: indexPath) {
            cell.loadImage(fade: true)
        } else {
            if let url = image.listUrl, ImageIO.isImageCached(url) {
                cell.loadImage(fade: false)
            }
        }
        return cell
    }
    
    private func willCellPerformEnterAnimation(indexPath: IndexPath) -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        }
        
        let maxCount = initialMaxVisibleCellCount
        if (animateCellFinished || maxCount < 0 || indexPath.row >= maxCount) {
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return
        }
        
        let maxCount = initialMaxVisibleCellCount
        if (animateCellFinished || maxCount < 0 || indexPath.row >= maxCount) {
            return
        }
        
        let index = indexPath.row
        
        if (index == maxCount - 1) {
            animateCellFinished = true
        }
        
        let startX = cell.center.x
        cell.alpha = 0.0
        cell.center.x += ImagesViewController.CELL_ANIMATE_OFFSET_X
        
        let delaySec = Double(index + 1) * ImagesViewController.CELL_ANIMATE_DELAY_UNIT_SEC
        
        UIView.animate(withDuration: ImagesViewController.CELL_ANIMATE_DURATION_SEC,
                       delay: delaySec,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        cell.alpha = 1.0
                        cell.center.x = startX
        },
                       completion: { (e) in
                        guard let cell = cell as? MainImageTableCell else {
                            return
                        }
                        cell.loadImage(fade: true)
        })
    }
}
