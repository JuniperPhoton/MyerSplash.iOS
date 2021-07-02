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
import MyerSplashShared

protocol ImagesViewControllerDelegate: AnyObject {
    func onClickImage(rect: CGRect, image: UnsplashImage, imageUrl: String) -> Bool
    func onRequestDownload(image: UnsplashImage)
}

extension ELWaterFlowLayout {
    static func calculateSpanCount(_ width: CGFloat)-> uint {
        let newSpan: uint
        switch width {
        case 0..<500:
            newSpan = 1
        case 500..<900:
            newSpan = 2
        case 900..<1600:
            newSpan = 3
        case 1600..<2200:
            newSpan = 4
        default:
            newSpan = 5
        }
        
        return newSpan
    }
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
    
    private(set) var imageRepo: ImageRepo? = nil
    
    private var indicator: MDCActivityIndicator!
    private var noItemView: UIView!
    private var loadingFooterView: MDCActivityIndicator!
    private var animateCellFinished = false
    
    private var viewDidLoaded = false
    
    private var noMoreItemView: UIView = {
        let label = UILabel()
        label.text = R.strings.no_more_items
        label.font = label.font.with(traits: .traitBold).withSize(16)
        label.textColor = .getDefaultLabelUIColor()
        label.sizeToFit()
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveReload), name: NSNotification.Name(AppNotification.KEY_RELOAD), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func shouldShowFilterButton() -> Bool {
        return imageRepo != nil && (imageRepo is RandomImageRepo || imageRepo is SearchImageRepo || imageRepo is DeveloperImageRepo)
    }
    
    override func viewDidLoad() {
        let view = self.view!
        
        imageRepo?.onLoadFinished = { [weak self] (_ success: Bool, _ page: Int, _ size: Int, _ startIndex: Int) in
            if let self = self {
                if !success {
                    showToast(R.strings.something_wrong)
                }
                
                self.indicator.stopAnimating()
                self.loading = false
                self.canLoadMore = size != 0
                self.loadingFooterView.stopAnimating()
                self.stopRefresh()
                
                if page == 1 {
                    self.calculateInitialMaxVisibleCellCount()
                }
                
                if !self.canLoadMore {
                    self.loadingFooterView.isHidden = true
                    self.noMoreItemView.isHidden = false
                }
                
                if self.imageRepo!.images.isEmpty {
                    self.updateHintViews(success)
                    self.loadingFooterView.isHidden = true
                    self.noMoreItemView.isHidden = true
                }
                
                if size > 0 {
                    self.collectionView.insertItems(at: [IndexPath(item: startIndex, section: 0)])
                    self.waterfallLayout.invalidateLayout()
                }
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
            waterfallLayout.lineCount = UInt(ELWaterFlowLayout.calculateSpanCount(UIApplication.shared.windows[0].bounds.width))
        } else {
            waterfallLayout.lineCount = 1
        }
        
        waterfallLayout.vItemSpace = Dimensions.ImagesViewSpace
        waterfallLayout.hItemSpace = Dimensions.ImagesViewSpace
        
        waterfallLayout.edge = UIEdgeInsets.init(top: 0, left: Dimensions.ImagesViewSpace, bottom: 0, right: Dimensions.ImagesViewSpace)
        
        collectionView.snp.makeConstraints { (maker) in
            maker.height.equalTo(view)
            maker.width.equalTo(view)
            maker.top.equalTo(view)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(
            top: collectionTopOffset,
            left: 0,
            bottom: ImagesViewController.FOOTER_HEIGHT.toCGFloat(),
            right: 0
        )
        collectionView.register(MainImageTableCell.self, forCellWithReuseIdentifier: MainImageTableCell.ID)
        
        loadingFooterView = MDCActivityIndicator()
        loadingFooterView.cycleColors = [.getDefaultLabelUIColor()]
        
        collectionView.addSubview(loadingFooterView)
        collectionView.addSubview(noMoreItemView)
        
        collectionView.dragDelegate = self
        
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
        
        viewDidLoaded = true
    }
    
    @objc
    private func onReceiveReload() {
        collectionView?.reloadData()
        waterfallLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !viewDidLoaded {
            return
        }
        let currentSpan = waterfallLayout.lineCount
        let newSpan = ELWaterFlowLayout.calculateSpanCount(size.width)
        
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
    
    func showTappedCell(withAlphaAnimation: Bool) {
        tappedCell?.isHidden = false
        
        if withAlphaAnimation {
            tappedCell?.alpha = 0.0

            UIView.animate(withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC, animations: {
                self.tappedCell?.alpha = 1.0
            })
        }
    }
    
    @objc
    func refreshData() {
        if errorHintView == nil {
            return
        }
        
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
        if (!canLoadMore || loading) {
            return
        }
        
        noMoreItemView.isHidden = true
        
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
            self.noMoreItemView.frame = frame;
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
        cell.onClickMainImage = { [weak self] (rect: CGRect, image: UnsplashImage, imageUrl: String) -> Void in
            if self?.delegate?.onClickImage(rect: rect, image: image, imageUrl: imageUrl) == true {
                cell.isHidden = true
                self?.tappedCell = cell
            }
        }
        
        let image = self.imageRepo!.images[indexPath.row]
        
        cell.bind(image: image)
        
        if !willCellPerformEnterAnimation(indexPath: indexPath) {
            cell.loadImage(fade: true)
        } else {
            if let url = image.listUrl, ImageIO.shared.isImageCached(url) {
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

extension ImagesViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        guard let images = imageRepo?.images else {
            return []
        }
        
        let row = indexPath.row
        
        if row < 0 || row >= images.count {
            return []
        }
        
        guard let url = images[row].listUrl else {
            return []
        }
        
        if !ImageIO.shared.isImageCached(url) {
            return []
        }
        
        let provider = NSItemProvider(object: ImageIO.shared.getCachedImage(url)!)
        
        return [
            UIDragItem(itemProvider: provider)
        ]
    }
}
