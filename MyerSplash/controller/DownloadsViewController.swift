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

class DownloadsViewController: UIViewController {
    fileprivate let waterfallLayout = ELWaterFlowLayout()
    
    private var downloadItems = [DownloadItem]()
    
    private var collectionView: UICollectionView!
    private var noItemView: UILabel!
    private var deleteFab: MDCFloatingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout)
        collectionView.showsVerticalScrollIndicator = false
        self.view.addSubview(collectionView)
        
        waterfallLayout.delegate = self
        waterfallLayout.scrollDirection = .vertical
        waterfallLayout.lineCount = 2
        waterfallLayout.vItemSpace = 12
        waterfallLayout.hItemSpace = 12
        waterfallLayout.edge = UIEdgeInsets.zero
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .getDefaultBackgroundUIColor()
        
        collectionView.register(DownloadItemCell.self, forCellWithReuseIdentifier: DownloadItemCell.ID)
        
        collectionView.snp.makeConstraints { (maker) in
            maker.left.top.equalToSuperview().offset(12)
            maker.right.equalToSuperview().offset(-12)
            maker.bottom.equalToSuperview()
        }
        
        // MARK: FAB
        let fab = MDCFloatingButton()
        let searchImage = UIImage.init(named: "ic_delete")?.withRenderingMode(.alwaysTemplate)
        fab.setImage(searchImage, for: .normal)
        fab.tintColor = UIColor.black
        fab.backgroundColor = UIColor.white
        fab.isHidden = true
        fab.addTarget(self, action: #selector(onClickDelete), for: .touchUpInside)
        self.view.addSubview(fab)
        self.deleteFab = fab

        fab.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.view).offset(-16)
            maker.bottom.equalTo(self.view).offset(UIView.hasTopNotch ? -24 : -16)
            maker.width.equalTo(50)
            maker.height.equalTo(50)
        }
        
        noItemView = UILabel()
        noItemView.isHidden = true
        noItemView.text = "No Items"
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
                self.reloadData()
            }
        }
    }
    
    @objc
    private func onClickDelete() {
        let vc = MDCAlertController(title: "Delete download history?", message: "This operation won't delete photos in your devices")
        vc.addAction(MDCAlertAction(title: "CANCEL", emphasis: .high, handler: {(action) in
            vc.dismiss(animated: true, completion: nil)
        }))
        vc.addAction(MDCAlertAction(title: "DELETE", handler: { [weak self] (action) in
            self?.deleteItems()
        }))
        self.present(vc, animated: true, completion: nil)
    }
    
    private func deleteItems() {
        DispatchQueue.global().async {
            AppDb.instance.deleteAll()
            
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
        let width = (collectionView.bounds.width - 10) / 2
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
        cell.bind(downloadItems[indexPath.row].unsplashImage!)
        cell.onClickEdit = { [weak self] (image) in
            self?.presentEdit(image: image)
        }
        cell.onClickDownload = { [weak self] (image) in
            guard let self = self else { return }
            DownloadManager.instance.prepareToDownload(vc: self, image: image)
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
