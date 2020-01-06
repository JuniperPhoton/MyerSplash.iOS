//
//  ImageRepo.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/5.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import SwiftyJSON

protocol Callback {
    func onNewImages(_ list: [UnsplashImage])
    func onFailed(_ e: Error?)
}

class NotImplError: Error {

}

class AppConcurrentDispatchQueueScheduler {
    private static var internalInstance: ConcurrentDispatchQueueScheduler? = nil

    static func instance() -> ConcurrentDispatchQueueScheduler {
        if internalInstance == nil {
            internalInstance = ConcurrentDispatchQueueScheduler(qos: .background)
        }
        return internalInstance!
    }
}

class ImageRepo {
    static let PAGING_PARAM = "page"
    static let PER_PAGE_PARAM = "per_page"
    static let DEFAULT_PER_PAGE = 10
    static let DEFAULT_HIGHLIGHTS_COUNT = 60

    var title: String = ""

    var images = [UnsplashImage]()

    private var disposeBag = DisposeBag()

    var onLoadFinished: ((_ success: Bool, _ page: Int) -> Void)? = nil

    func loadImage(_ page: Int) {
        loadImagesInternal(page)
                .subscribeOn(AppConcurrentDispatchQueueScheduler.instance())
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (list) in
                    if page == 1 {
                        self.images.removeAll()
                    }

                    list.forEach { (image) in
                        self.images.append(image)
                    }

                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.onLoadFinished?.self(true, page)
                }, onError: { (e) in
                    print("Error on loading image: %s", e.localizedDescription)
                    self.onLoadFinished?.self(false, page)
                })
                .disposed(by: disposeBag)
    }

    func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        return Observable.error(NotImplError())
    }
}

class HighlightsImageRepo: ImageRepo {
    override var title: String {
        get {
            return "HIGHLIGHTS"
        }
        set {
            // read only
        }
    }

    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        return Single.create { (e) -> Disposable in
                    var result = [UnsplashImage]()
                    let calendar = Calendar(identifier: Calendar.Identifier.republicOfChina)
                    let startDate = calendar.date(byAdding: Calendar.Component.day,
                            value: -(page - 1) * ImageRepo.DEFAULT_HIGHLIGHTS_COUNT, to: Date())!

                    for i in (0..<ImageRepo.DEFAULT_HIGHLIGHTS_COUNT) {
                        let date = calendar.date(byAdding: Calendar.Component.day,
                                value: -i,
                                to: startDate)!
                        result.append(UnsplashImage.create(date))
                    }

                    e(.success(result))

                    return Disposables.create()
                }
                .delaySubscription(RxTimeInterval.milliseconds(200), scheduler: AppConcurrentDispatchQueueScheduler.instance()).asObservable()
    }
}

extension Observable {
    func mapToList(appendTodayImage: Bool = false) -> Observable<[UnsplashImage]> {
        return self.map { jsonResponse in
            let json = JSON(jsonResponse)
            var images: [UnsplashImage] = json.compactMap { s, json -> UnsplashImage? in
                UnsplashImage(json)
            }

            if appendTodayImage {
                images.insert(UnsplashImage.createToday(), at: 0)
            }
            return images
        }
    }
}

class NewImageRepo: ImageRepo {
    override var title: String {
        get {
            return "NEW"
        }
        set {
            // read only
        }
    }

    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        return json(.get, Request.PHOTO_URL, parameters: CloudService.getDefaultParams(paging: page)).mapToList(appendTodayImage: page == 1)
    }
}

class RandomImageRepo: ImageRepo {
    override var title: String {
        get {
            return "RANDOM"
        }
        set {
            // read only
        }
    }

    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        var params = CloudService.getDefaultParams(paging: page)
        params["count"] = 30
        return json(.get, Request.RANDOM_PHOTOS_URL, parameters: params).mapToList()
    }
}

class DeveloperImageRepo: ImageRepo {
    override var title: String {
        get {
            return "DEVELOPER"
        }
        set {
            // read only
        }
    }

    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        return json(.get, Request.DEVELOPER_PHOTOS_URL, parameters: CloudService.getDefaultParams(paging: page)).mapToList()
    }
}

class SearchImageRepo: ImageRepo {
    override var title: String {
        get {
            return "SEARCH"
        }
        set {
            // read only
        }
    }

    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        return Observable.error(NotImplError())
    }
}
