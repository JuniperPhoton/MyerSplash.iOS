import Foundation
import UIKit
import SwiftyJSON

class UnsplashImage {
    private (set) var id:    String?
    private (set) var color: String?
    private (set) var likes: Int = 0
    private (set) var urls:  ImageUrl?
    private (set) var user:  UnsplashUser?
    private (set) var isUnsplash = true

    var fileNameForDownload: String {
        get {
            return "\(user!.name!) - \(id!) - \(tagForDownload)"
        }
    }

    var themeColor: UIColor {
        get {
            return color != nil ? UIColor(color!) : UIColor.black
        }
    }

    var userName: String? {
        get {
            return user?.name
        }
    }

    var userHomePage: String? {
        get {
            return user?.homeUrl
        }
    }

    var listUrl: String? {
        get {
            let quality = AppSettings.loadingQuality()
            switch quality {
                case 0: return urls?.regular
                case 1: return urls?.small
                case 2: return urls?.thumb
                default: return urls?.regular
            }
        }
    }

    var downloadUrl: String? {
        get {
            let quality = AppSettings.savingQuality()
            switch quality {
                case 0: return urls?.raw
                case 1: return urls?.full
                case 2: return urls?.regular
                default: return urls?.full
            }
        }
    }

    var fileName: String {
        get {
            let name = user?.name ?? "author"
            let id   = self.id ?? "id"
            return "\(name)-\(id)-\(tagForDownload).jpg"
        }
    }

    private var tagForDownload: String {
        get {
            let quality = AppSettings.savingQuality()
            switch quality {
                case 0: return "raw"
                case 2: return "regular"
                default: return "full"
            }
        }
    }

    init() {
    }

    init?(_ j: JSON?) {
        guard let json = j else {
            return nil
        }

        id = json["id"].string

        if (id == nil) {
            return nil
        }

        color = json["color"].string
        likes = json["likes"].intValue

        urls = ImageUrl(json["urls"])
        user = UnsplashUser(json["user"])
    }

    static func isToday(_ image: UnsplashImage) -> Bool {
        return image.id == "TodayImage"
    }

    static func createTodayImageId() -> String {
        return createTodayImageDateString()
    }

    static func createTodayImageDateString() -> String {
        return createDateString(Date())
    }

    static func createDateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        return df.string(from: date)
    }

    static func create(_ date: Date) -> UnsplashImage {
        let image = UnsplashImage()
        let urls  = ImageUrl()
        let user  = UnsplashUser()
        user.userName = "JuniperPhoton"
        user.name = "JuniperPhoton"
        user.id = "JuniperPhoton"

        let profileUrl = ProfileUrl()
        profileUrl.html = Request.ME_HOME_PAGE
        user.links = profileUrl

        let dateStr = createDateString(date)

        urls.raw = "\(Request.AUTO_CHANGE_WALLPAPER)\(dateStr).jpg"
        urls.full = "\(Request.AUTO_CHANGE_WALLPAPER)\(dateStr).jpg"
        urls.regular = "\(Request.AUTO_CHANGE_WALLPAPER_THUMB)\(dateStr).jpg"
        urls.small = "\(Request.AUTO_CHANGE_WALLPAPER_THUMB)\(dateStr).jpg"
        urls.thumb = "\(Request.AUTO_CHANGE_WALLPAPER_THUMB)\(dateStr).jpg"

        image.color = "#ffffff"
        image.id = dateStr
        image.urls = urls
        image.user = user
        image.isUnsplash = false
        return image
    }

    static func createToday() -> UnsplashImage {
        return create(Date())
    }
}

class ImageUrl {
    var raw:     String?
    var full:    String?
    var regular: String?
    var small:   String?
    var thumb:   String?

    init() {
    }

    init?(_ j: JSON?) {
        guard let json = j else {
            return nil
        }
        raw = json["raw"].string
        full = json["full"].string
        regular = json["regular"].string
        small = json["small"].string
        thumb = json["thumb"].string
    }
}
