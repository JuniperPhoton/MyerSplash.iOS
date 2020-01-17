//
//  DownloadManager.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/8.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import MaterialComponents.MDCAlertController
import Alamofire
import RxAlamofire
import RxSwift

class DownloadManager: NSObject {
    static let instance = DownloadManager()
    
    private var publishSubject = PublishSubject<DownloadItem>()
    private var downloadRecord = [String: DownloadRequest]()
    
    private static let TAG = "DownloadManager"
    
    static let DOWNLOAD_DIR = "MyerSplash"

    private override init() {
        // ignored
    }
    
    func markDownloadingToFailed() {
        dbQueue.async {
            AppDb.instance.updateItemsToFailed()
        }
    }
    
    func addObserver(_ image: UnsplashImage, _ observer: @escaping (Event<DownloadItem>) -> Void) -> Disposable {
        let disposable = publishSubject.observeOn(MainScheduler.instance).subscribe(observer)
        
        checkDownloadStatusFirst(image)
        
        return disposable
    }
    
    private func checkDownloadStatusFirst(_ image: UnsplashImage) {
        dbQueue.async {
            guard let item = AppDb.instance.queryItemById(id: image.id!) else {
                let fakeItem = DownloadItem()
                fakeItem.id = image.id
                self.publishSubject.onNext(fakeItem)
                return
            }
            
            print("found download item in \(Thread.current)")
            self.publishSubject.onNext(item)
        }
    }
    
    func cancel(id: String) {
        let request = downloadRecord[id]
        if request != nil {
            showToast(R.strings.download_cancelled)
            Log.warn(tag: DownloadManager.TAG, "begin to cancel")
            request?.cancel()
        } else {
            Log.warn(tag: DownloadManager.TAG, "can't find request to cancel")
        }
    }
    
    // MARK: Check first
    func prepareToDownload(vc: UIViewController,
                           image: UnsplashImage) {
        Events.trackBeginDownloadEvent()
        
        var reachability: Reachability!
        
        do {
            reachability = try Reachability()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        if reachability.connection != .unavailable {
            print("isReachable")
        } else {
            print("is NOT Reachable")
            vc.view.showToast(R.strings.no_network)
            return
        }
        
        if reachability.connection != .wifi {
            print("NOT using wifi")
            if AppSettings.isMeteredEnabled() {
                let alertController = MDCAlertController(
                    title: R.strings.metered_dialog_title,
                    message: R.strings.metered_dialog_message)
                alertController.applyColors()
                let ok = MDCAlertAction(title: R.strings.download) { (action) in
                    self.doDownload(image)
                }
                let cancel = MDCAlertAction(title: R.strings.cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(ok)
                alertController.addAction(cancel)
                
                vc.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        doDownload(image)
    }
    
    func createAbsolutePathForImage(_ relativePath: String)-> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent(relativePath)
    }
    
    private func doDownload(_ unsplashImage: UnsplashImage) {
        if downloadRecord[unsplashImage.id!] != nil {
            Log.warn(tag: DownloadManager.TAG, "already downloading...")
            return
        }
        
        print("downloading: \(unsplashImage.downloadUrl ?? "")")
        
        let item = DownloadItem()
        item.id = unsplashImage.id
        item.unsplashImage = unsplashImage
        item.status = DownloadStatus.Downloading.rawValue
        
        let insertWork = DispatchWorkItem {
            AppDb.instance.insertToDb(item)
        }
        
        dbQueue.sync(execute: insertWork)
        
        insertWork.notify(queue: DispatchQueue.main, execute: {
            showToast(R.strings.download_in_background)
            
            let relativePath = "\(DownloadManager.DOWNLOAD_DIR)/\(unsplashImage.fileName)"
            let fileURL = self.createAbsolutePathForImage(relativePath)
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            self.publishSubject.onNext(item)
            
            let request = Alamofire.download(unsplashImage.downloadUrl!, to: destination).downloadProgress(closure: { (progress) in
                self.notifyProgress(downloadItem: item, progress: Float(progress.fractionCompleted))
            }).response { response in
                self.downloadRecord.removeValue(forKey: item.id!)
                
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    Log.info(tag: DownloadManager.TAG, "image downloaded!")
                    
                    Events.trackDownloadSuccessEvent()
                    
                    self.notifySuccess(downloadItem: item, imagePath: relativePath)
                    UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: imagePath)!, self, #selector(self.onSavedOrError), nil)
                } else {
                    Log.info(tag: DownloadManager.TAG, "error while download image: \(response.error?.localizedDescription ?? "null error")")
                    self.notifyFailed(downloadItem: item)
                    Events.trackDownloadFailedEvent(false, response.error?.localizedDescription)
                }
            }
            
            self.downloadRecord[unsplashImage.id!] = request
        })
    }
    
    @objc
    private func onSavedOrError(_ image: UIImage,
                                didFinishSavingWithError error: Error?,
                                contextInfo: UnsafeRawPointer) {
        DownloadManager.showSavedToastOnVC(success: error == nil)
    }
    
    private var dbQueue = DispatchQueue(label: "db_queue")
    
    private func insertItemAndNotify(downloadItem: DownloadItem) {
        dbQueue.async {
            AppDb.instance.insertOrReplace(downloadItem)
            self.publishSubject.onNext(downloadItem)
        }
    }
    
    private func notifyProgress(downloadItem: DownloadItem, progress: Float) {
        if progress - downloadItem.progress < 0.1 {
            return
        }
        
        downloadItem.progress = progress
        downloadItem.status = DownloadStatus.Downloading.rawValue
        
        insertItemAndNotify(downloadItem: downloadItem)
    }
    
    private func notifySuccess(downloadItem: DownloadItem, imagePath: String) {
        downloadItem.progress = 1
        downloadItem.fileURL = imagePath
        downloadItem.status = DownloadStatus.Success.rawValue
        
        insertItemAndNotify(downloadItem: downloadItem)
    }
    
    private func notifyFailed(downloadItem: DownloadItem) {
        downloadItem.progress = 0
        downloadItem.fileURL = nil
        downloadItem.status = DownloadStatus.Failed.rawValue
        
        insertItemAndNotify(downloadItem: downloadItem)
    }
    
    static func showSavedToastOnVC(success: Bool) {
        if success {
            showToast(R.strings.saved_album)
        } else {
            showToast(R.strings.failed_save)
        }
    }
}
