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

protocol ImagesViewControllerDelegate {
    func onClickImage(rect: CGRect, image: UnsplashImage)
    func onRequestDownload(image: UnsplashImage)
}

class ImagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    enum AnimatingStatus {
           case STILL, SHOWING, HIDING
    }
    
    static func calculateCellHeight(_ width: CGFloat) -> CGFloat {
        return width / 1.5 // todo
    }

    static let CELL_ANIMATE_OFFSET_X: CGFloat = 50.0
    static let CELL_ANIMATE_DELAY_UNIT_SEC = 0.1
    static let CELL_ANIMATE_DURATION_SEC = 0.4

    static let HIGHLIGHTS_DELAY_SEC = 0.2

    private var images: [UnsplashImage] = [UnsplashImage]()

    private var loadingFooterView: LoadingFooterView!

    private var paging = 1
    private var loading = false
    private var canLoadMore = false

    private var calculatedCellHeight: CGFloat = -1.0
    private var initialMaxVisibleCellCount = -1

    private var cellDisplayAnimatedCount = 0

    private var tappedCell: UITableViewCell? = nil
    
    private var animatingStatus: AnimatingStatus = AnimatingStatus.STILL
    private var startY: CGFloat = -1

    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    
    private var imageRepo: ImageRepo? = nil
    
    var delegate: ImagesViewControllerDelegate? = nil
    
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
        
        view.backgroundColor = UIView.getDefaultBackgroundUIColor()
        
        refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.addTarget(self, action: #selector(onRefreshData), for: .valueChanged)

        tableView = UITableView(frame: CGRect.zero)

        tableView.setDefaultBackgroundColor()
        tableView.refreshControl = refreshControl

        view.addSubview(tableView)

        tableView.snp.makeConstraints { (maker) in
            maker.height.equalTo(view)
            maker.width.equalTo(view)
            maker.top.equalTo(view)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MainImageTableCell.self, forCellReuseIdentifier: MainImageTableCell.ID)
        tableView.separatorStyle = .none

        refreshData()
    }
    
    func showTappedCell() {
        tappedCell?.isHidden = false
    }

    private func refreshData() {
        paging = 1
        loadData(true)
    }

    private func loadData(_ refreshing: Bool) {
        if (loading) {
            NSLog("@string", "loading...")
            //return
        }

        loading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + ImagesViewController.HIGHLIGHTS_DELAY_SEC) {
            CloudService.getHighlights(page: self.paging) { response in
                self.processResponse(response: response, refreshing)
                self.loading = false
                self.canLoadMore = !response.isEmpty
                self.stopRefresh()
            }
        }
    }

    private func processResponse(response: [UnsplashImage], _ refreshing: Bool) {
        if (images.count >= 2 && response.count > 0) {
            let firstResponseImage = response.first!
            let firstExistImage = images[1]

            let todayHighlightUpdated = !firstExistImage.isUnsplash
                    && firstExistImage.id != UnsplashImage.createTodayImageId()

            let noNewData = firstExistImage.id == firstResponseImage.id

            // Today highlight is not updated and the first images are match, skip reload data.
            if (noNewData && !todayHighlightUpdated) {
                view.showToast("No new data")
                return
            }
        }

        if (refreshing) {
            images.removeAll(keepingCapacity: false)
            cellDisplayAnimatedCount = 0
        }

        images += response
        tableView.reloadData()
    }

    private func loadMore() {
        if (!canLoadMore) {
            return
        }
        paging = paging + 1
        loadData(false)
    }
    
    func hideNavigationElements() {
        if (animatingStatus == AnimatingStatus.HIDING) {
            return
        }

        animatingStatus = AnimatingStatus.HIDING

        UIView.animate(
                withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseInOut,
                animations: {
                    self.view.layoutIfNeeded()
                },
                completion: { c in
                    self.animatingStatus = AnimatingStatus.STILL
                })
    }

    func showNavigationElements() {
        if (animatingStatus == AnimatingStatus.SHOWING) {
            return
        }

        animatingStatus = AnimatingStatus.SHOWING

        UIView.animate(
                withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseInOut,
                animations: {
                    self.view.layoutIfNeeded()
                },
                completion: { c in
                    self.animatingStatus = AnimatingStatus.STILL
                })
    }

    func stopRefresh() {
        refreshControl.endRefreshing()
    }

    @objc
    private func onRefreshData() {
        self.refreshData()
        
        if (refreshControl.isRefreshing) {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MainImageTableCell.ID, for: indexPath) as? MainImageTableCell else {
            fatalError()
        }
        cell.onClickDownload = { unsplashImage in
            self.delegate?.onRequestDownload(image: unsplashImage)
        }
        cell.onClickMainImage = { (rect: CGRect, image: UnsplashImage) -> Void in
            print("rect is %@", rect)
            cell.isHidden = true
            self.tappedCell = cell
            self.delegate?.onClickImage(rect: rect, image: image)
        }
        cell.bind(image: images[indexPath.row])
        return cell
    }

    // For iOS 11, this method must be conform to provide estimated height.
    // After calling table view's reloadData(), all the items' contents size will be re-calculated,
    // and the table view use estimated height as content size at first,
    // which leads to the incorrect content size of table view.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        calculateAndCacheCellHeight()
        return calculatedCellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        calculateAndCacheCellHeight()
        return calculatedCellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = calculateInitialMaxVisibleCellCount()
        if (count < 0) {
            return
        }

        if (cellDisplayAnimatedCount >= count) {
            return
        }

        let index = indexPath.row
        if (index >= count) {
            return
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
                completion: nil)

        cellDisplayAnimatedCount += 1
    }

    private func calculateInitialMaxVisibleCellCount() -> Int {
        if (initialMaxVisibleCellCount == -1) {
            calculateAndCacheCellHeight()

            guard let tableView = tableView else {
                return initialMaxVisibleCellCount
            }

            let visibleHeight = tableView.frame.height
            initialMaxVisibleCellCount = Int(ceil(Double(visibleHeight) / Double(calculatedCellHeight)))
        }

        return initialMaxVisibleCellCount
    }

    private func calculateAndCacheCellHeight() {
        if (calculatedCellHeight == -1.0) {
            calculatedCellHeight = ImagesViewController.calculateCellHeight(UIScreen.main.bounds.width)
        }
    }

    // MARK: scroll

    private var lastScrollOffset: CGPoint = CGPoint(x: 0, y: 0)

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We don't want the over-scrolling takes any showing & hiding effect.
        if (scrollView.contentOffset.y <= 0) {
            return
        }

        if (scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height) {
            loadMore()
        }

        let dy = scrollView.contentOffset.y - lastScrollOffset.y
        if (dy > 10) {
            hideNavigationElements()
        } else if (dy < -10) {
            showNavigationElements()
        }

        lastScrollOffset = scrollView.contentOffset
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y <= 0) {
            showNavigationElements()
        }
    }
}
