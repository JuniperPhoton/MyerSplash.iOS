//
//  DownloadManager.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/8.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift

public class DownloadManager: NSObject {
    public static let shared = {
       DownloadManager()
    }()
    
    private var publishSubject = PublishSubject<DownloadItem>()
    private var downloadRecord = [String: DownloadRequest]()
    
    private static let TAG = "DownloadManager"
    
    public static let DOWNLOAD_DIR = "MyerSplash"

    private var dbQueue = DispatchQueue(label: "db_queue")

    private override init() {
        // ignored
    }
    
    public func markDownloadingToFailed() {
        dbQueue.async {
            AppDb.instance.updateItemsToFailed()
        }
    }
    
    public func addObserver(_ image: UnsplashImage, _ observer: @escaping (Event<DownloadItem>) -> Void) -> Disposable {
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
    
    public func cancel(id: String) {
        let request = downloadRecord[id]
        if request != nil {
            showToast(R.strings.download_cancelled)
            Log.warn(tag: DownloadManager.TAG, "begin to cancel")
            request?.cancel()
        } else {
            Log.warn(tag: DownloadManager.TAG, "can't find request to cancel")
        }
    }
        
    public func createSavingDir()-> URL {
        #if targetEnvironment(macCatalyst)
        return FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)[0].appendingPathComponent(DownloadManager.DOWNLOAD_DIR)
        #else
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(DownloadManager.DOWNLOAD_DIR)
        #endif
    }
    
    public func createSavingRootPath()-> URL {
        #if targetEnvironment(macCatalyst)
        return FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)[0]
        #else
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        #endif
    }
    
    public func createAbsolutePathForImage(_ relativePath: String)-> URL {
        return createSavingRootPath().appendingPathComponent(relativePath)
    }
    
    public func downloadImage(_ unsplashImage: UnsplashImage,
                              onStart: @escaping (_ request: DownloadRequest) -> Void,
                              onSuccess: @escaping (_ fileURL: URL) -> Void,
                              onFailure: @escaping () -> Void) {
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
            let fileURL = DownloadManager.shared.createAbsolutePathForImage(relativePath)
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            self.publishSubject.onNext(item)
            
            let request = Alamofire.download(unsplashImage.downloadUrl!, to: destination).downloadProgress(closure: { (progress) in
                self.notifyProgress(downloadItem: item, progress: Float(progress.fractionCompleted))
            }).response { response in
                self.downloadRecord.removeValue(forKey: item.id!)
                
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    Log.info(tag: DownloadManager.TAG, "image downloaded! imagePath is \(imagePath), relativePath is \(relativePath), fileURL is \(fileURL)")
                    
                    Events.trackDownloadSuccessEvent()
                    
                    self.notifySuccess(downloadItem: item, imagePath: relativePath)
                    onSuccess(fileURL)
                } else {
                    Log.info(tag: DownloadManager.TAG, "error while download image: \(response.error?.localizedDescription ?? "null error")")
                    self.notifyFailed(downloadItem: item)
                    Events.trackDownloadFailedEvent(false, response.error?.localizedDescription)
                    onFailure()
                }
            }
            
            self.downloadRecord[unsplashImage.id!] = request
        })
    }
    
    public func downloadImage(_ unsplashImage: UnsplashImage) {
        self.downloadImage(unsplashImage) { Request in
            // ignored
        } onSuccess: { fileURL in
            let imagePath = fileURL.path
            #if !targetEnvironment(macCatalyst)
            UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: imagePath)!, self, #selector(self.onSavedOrError), nil)
            #else
            showToast(R.strings.saved_mac, time: 4)
            #endif
        } onFailure: {
            // ignored
        }
    }
    
    @objc
    private func onSavedOrError(_ image: UIImage,
                                didFinishSavingWithError error: Error?,
                                contextInfo: UnsafeRawPointer) {
        DownloadManager.showSavedToastOnVC(success: error == nil)
    }
        
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
