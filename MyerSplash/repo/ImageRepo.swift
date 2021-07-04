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
import MyerSplashShared

let decoder = JSONDecoder()

protocol Callback {
    func onNewImages(_ list: [UnsplashImage])
    func onFailed(_ e: Error?)
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
    var filterOption = FilterOption.All
    var contentSafety = ContentSafety.Low
    
    private var disposeBag = DisposeBag()
    
    var onLoadFinished: ((_ success: Bool, _ page: Int, _ loadedSize: Int, _ startIndex: Int) -> Void)? = nil
    
    func loadImage(_ page: Int) {
        let startTime = NetworkQuality.sharedInstance.getCurrentTimeMillis()

        loadImagesInternal(page)
            .subscribeOn(AppConcurrentDispatchQueueScheduler.instance())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (list) in
                NetworkQuality.sharedInstance.recordDownloadDuration(startMillis: startTime, success: true)
                
                if page == 1 {
                    self.images.removeAll()
                }
                
                list.forEach { (image) in
                    self.images.append(image)
                }
                
                self.onLoadFinished?.self(true, page, list.count, self.images.count - list.count)
            }, onError: { (e) in
                NetworkQuality.sharedInstance.recordDownloadDuration(startMillis: startTime, success: false)

                print("Error on loading image: %s", e.localizedDescription)
                self.onLoadFinished?.self(false, page, 0, 0)
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
            return R.strings.tab_highlights
        }
        set {
            // read only
        }
    }
    
    private let endDate: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: "2018/03/20")!
    }()
    
    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        return Single.create { (e) -> Disposable in
            var result = [UnsplashImage]()
            let calendar = NSCalendar.autoupdatingCurrent
            let startDate = calendar.date(byAdding: Calendar.Component.day,
                                          value: -(page - 1) * ImageRepo.DEFAULT_HIGHLIGHTS_COUNT,
                                          to: Date())!
            
            for i in (0..<ImageRepo.DEFAULT_HIGHLIGHTS_COUNT) {
                let date = calendar.date(byAdding: Calendar.Component.day,
                                         value: -i,
                                         to: startDate)!
                
                if date > self.endDate {
                    result.append(UnsplashImage.create(date))
                } else {
                    let dateFormatterPrint = DateFormatter()
                    dateFormatterPrint.dateFormat = "yyyy/MM/dd"
                    let endString = dateFormatterPrint.string(from: date)
                    print("end date string is \(endString)")
                    break
                }
            }
            
            e(.success(result))
            
            return Disposables.create()
        }
        .delaySubscription(RxTimeInterval.milliseconds(200), scheduler: AppConcurrentDispatchQueueScheduler.instance()).asObservable()
    }
}

class NewImageRepo: ImageRepo {
    override var title: String {
        get {
            return R.strings.tab_new
        }
        set {
            // read only
        }
    }
    
    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        return json(.get, Request.PHOTO_URL,
                    parameters: Request.getDefaultParams(paging: page, filter: filterOption)).mapToList(appendTodayImage: page == 1)
    }
}

class RandomImageRepo: ImageRepo {
    override var title: String {
        get {
            return R.strings.tab_random
        }
        set {
            // read only
        }
    }
    
    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        var params = Request.getDefaultParams(paging: page, filter: filterOption, contentSafety: contentSafety)
        params["count"] = 30
        return json(.get, Request.RANDOM_PHOTOS_URL, parameters: params).mapToList()
    }
}

class WallpaperRepo: ImageRepo {
    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        var params = Request.getDefaultParams(paging: page, filter: filterOption, contentSafety: contentSafety)
        params["count"] = 1
        return json(.get, Request.WALLPAPER_URL, parameters: params).mapToList()
    }
}

class DeveloperImageRepo: ImageRepo {
    override var title: String {
        get {
            return R.strings.tab_developer
        }
        set {
            // read only
        }
    }
    
    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        return json(.get, Request.DEVELOPER_PHOTOS_URL,
                    parameters: Request.getDefaultParams(paging: page, filter: filterOption)).mapToList()
    }
}

class PhotographerImageRepo: ImageRepo {
    private let authorName: String
    
    init(authorName: String) {
        self.authorName = authorName
        super.init()
    }
    
    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        let url = Request.PHOTOGRAPHER_PHOTOS_URL
        let requestUrl = String(format: url, authorName)
        
        print(requestUrl)
        return json(.get, requestUrl,
                    parameters: Request.getDefaultParams(paging: page, filter: filterOption)).mapToList()
    }
}

class SearchImageRepo: ImageRepo {    
    private var query: String? = nil
    
    init(query: String?) {
        self.query = query
        super.init()
    }
    
    override func loadImagesInternal(_ page: Int) -> Observable<[UnsplashImage]> {
        if query == nil || query == "" {
            return Observable.error(ApiError(message: "query should not be nil"))
        }
        
        var params = Request.getDefaultParams(paging: page, filter: filterOption)
        params["query"] = query
        
        return json(.get, Request.SEARCH_URL, parameters: params)
            .map { jsonResponse in
                let json = JSON(jsonResponse)
                return json["results"].createList() ?? [UnsplashImage]()
        }
    }
}

extension Observable {
    func mapToList(appendTodayImage: Bool = false) -> Observable<[UnsplashImage]> {
        return self.map { jsonResponse in
            let json = JSON(jsonResponse)
            var images: [UnsplashImage]? = json.createList()
            
            if images == nil {
                images = [UnsplashImage]()
            }
            
            if (AppSettings.isNoSponsorshipEnabled()) {
                images?.removeAll(where: { (image) -> Bool in
                    return image.sponsorship != nil
                })
            }
            
            if appendTodayImage {
                images?.insert(UnsplashImage.createToday(), at: 0)
            }
            return images!
        }
    }
}

extension JSON {
    fileprivate func createList()-> [UnsplashImage]? {
        return self.compactMap { element in
            let json = element.1.rawString()
            let image = try? decoder.decode(UnsplashImage.self, from: json!.data(using: .utf8)!)
            return image
        }
    }
}
