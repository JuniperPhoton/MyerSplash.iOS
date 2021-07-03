//
//  DownloadsViewController.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/6.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import ELWaterFallLayout
import MaterialComponents
import MyerSplashShared

class DownloadsViewController: UIViewController {
    fileprivate let waterfallLayout = ELWaterFlowLayout()
    
    private var downloadItems = [DownloadItem]()
    
    private var collectionView: UICollectionView!
    private var noItemView: UILabel!
    private var deleteFab: MDCFloatingButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveReload), name: NSNotification.Name(AppNotification.KEY_RELOAD), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout)
        collectionView.showsVerticalScrollIndicator = false
        self.view.addSubview(collectionView)
        
        waterfallLayout.delegate = self
        waterfallLayout.scrollDirection = .vertical
                
        if UIDevice.current.userInterfaceIdiom == .pad {
            print("run for pad")
            waterfallLayout.lineCount = UInt(ELWaterFlowLayout.calculateSpanCount(
                UIApplication.shared.windows[0].bounds.width))
        } else {
            print("run for phone")
            waterfallLayout.lineCount = 2
        }
        
        waterfallLayout.vItemSpace = Dimensions.ImagesViewSpace
        waterfallLayout.hItemSpace = Dimensions.ImagesViewSpace
        waterfallLayout.edge = UIEdgeInsets(top: Dimensions.ImagesViewSpace, left: Dimensions.ImagesViewSpace, bottom: Dimensions.ImagesViewSpace, right: Dimensions.ImagesViewSpace)

        collectionView.contentInset = UIEdgeInsets(top: getContentTopInsets(), left: 0, bottom: 0, right: 0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .getDefaultBackgroundUIColor()
        
        collectionView.register(DownloadItemCell.self, forCellWithReuseIdentifier: DownloadItemCell.ID)
        
        collectionView.snp.makeConstraints { (maker) in
            maker.left.top.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        // MARK: FAB
        let fab = MDCFloatingButton()
        let searchImage = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        fab.setImage(searchImage, for: .normal)
        fab.tintColor = UIColor.black
        fab.backgroundColor = UIColor.white
        fab.isHidden = true
        fab.addTarget(self, action: #selector(onClickDelete), for: .touchUpInside)
        self.view.addSubview(fab)
        self.deleteFab = fab
        
        self.collectionView.dragDelegate = self

        fab.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.view).offset(-16)
            maker.bottom.equalTo(self.view).offset(UIView.hasTopNotch ? -24 : -16)
            maker.width.equalTo(50)
            maker.height.equalTo(50)
        }
        
        noItemView = UILabel()
        noItemView.isHidden = true
        noItemView.text = R.strings.no_items
        noItemView.textColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3)
        noItemView.font = noItemView.font.withSize(24)
        self.view.addSubview(noItemView)

        noItemView.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
        }
        
        DispatchQueue.global().async {
            let collection = AppDb.instance.getAllItems()
            for c in collection {
                self.downloadItems.append(c)
            }
            
            print("collections in db, count is ", self.downloadItems.count)

            DispatchQueue.main.sync {
                UIView.performWithoutAnimation {
                    self.reloadData()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if collectionView?.superview == nil {
            return
        }
        let currentSpan = waterfallLayout.lineCount
        let newSpan = ELWaterFlowLayout.calculateSpanCount(size.width)
        
        if newSpan != currentSpan {
            waterfallLayout.lineCount = UInt(newSpan)
            collectionView.setNeedsLayout()
        }
    }
    
    @objc
    private func onReceiveReload() {
        UIView.performWithoutAnimation {
            collectionView?.reloadData()
            waterfallLayout.invalidateLayout()
        }
    }
    
    @objc
    private func onClickDelete() {
        let vc = MDCAlertController(title: R.strings.delete_dialog_title, message: R.strings.delete_dialog_message)
        vc.applyColors()
        vc.addAction(MDCAlertAction(title: R.strings.cancel, emphasis: .high, handler: { (action) in
            vc.dismiss(animated: true, completion: nil)
        }))
        vc.addAction(MDCAlertAction(title: R.strings.delete_dialog_action_delete, handler: { [weak self] (action) in
            self?.deleteItems()
        }))
        self.present(vc, animated: true, completion: nil)
    }
    
    private func deleteItems() {
        DispatchQueue.global().async {
            AppDb.instance.deleteAll()
            ImageIO.shared.clearDownloadFiles()
            
            DispatchQueue.main.async {
                self.downloadItems.removeAll()
                self.reloadData()
            }
        }
    }
    
    private func reloadData() {
        if downloadItems.isEmpty {
            deleteFab.isHidden = true
            noItemView.isHidden = false
        } else {
            deleteFab.isHidden = false
            noItemView.isHidden = true
        }
        
        collectionView.reloadData()
    }
}

extension DownloadsViewController: UICollectionViewDelegate, ELWaterFlowLayoutDelegate, UICollectionViewDataSource {
    func el_flowLayout(_ flowLayout: ELWaterFlowLayout, heightForRowAt index: Int) -> CGFloat {
        let space = waterfallLayout.hItemSpace * CGFloat(waterfallLayout.lineCount - 1) + waterfallLayout.edge.left + waterfallLayout.edge.right
        let width = CGFloat(collectionView.bounds.width) / CGFloat(waterfallLayout.lineCount) - space
        
        let aspectRatio = downloadItems[index].unsplashImage!.rawAspectRatioF
        let height = width / aspectRatio
        return height + CGFloat(DownloadItemCell.BOTTOM_BUTTON_HEIGHT)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
        
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return downloadItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadItemCell.ID, for: indexPath) as! DownloadItemCell
        
        let downloadItem = self.downloadItems[indexPath.row]

        cell.bind(downloadItem.unsplashImage!)
        cell.onClickEdit = { [weak self] (image) in
            guard let self = self else { return }
            let downloadItem = self.downloadItems[indexPath.row]
            self.presentEdit(item: downloadItem)
        }
        cell.onClickDownload = { [weak self] (image) in
            guard let self = self else { return }
            DownloadManager.instance.prepareToDownload(vc: self, image: image)
        }
        cell.onDownloadItemUpdated = { [weak self] (item) in
            guard let self = self else { return }
            self.downloadItems[indexPath.row] = item
            Log.info(tag: "downloadcollection", "update item at row \(indexPath.row), filePath: \(item.fileURL ?? "")")
        }
        cell.onClickShare = { [weak self] (item) in
            guard let self = self else { return }
            self.presentShare(item, cell.shareButton)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DownloadItemCell else {
            return
        }
        
        cell.unbind()
    }
}

extension DownloadsViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        let row = indexPath.row
        
        if row < 0 || row >= downloadItems.count {
            return []
        }
        
        let image = downloadItems[row]
        
        // Use downloaded image if possible
        if image.status == DownloadStatus.Success.rawValue, let path = image.fileURL {
            let url = DownloadManager.instance.createAbsolutePathForImage(path).path

            if let image = UIImage(contentsOfFile: url) {
                let provider = NSItemProvider(object: image)
                return [UIDragItem(itemProvider: provider)]
            }
        }
        
        guard let url = image.unsplashImage?.listUrl else {
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
