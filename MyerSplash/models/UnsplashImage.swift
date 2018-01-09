import Foundation
import UIKit
import SwiftyJSON

class UnsplashImage {
    private (set) var id: String?
    private (set) var color: String?
    private (set) var likes: Int = 0
    private (set) var urls: ImageUrl?
    private (set) var user: UnsplashUser?
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
            return urls?.regular
        }
    }

    var downloadUrl: String? {
        get {
            return urls?.full
        }
    }

    var fileName: String {
        get {
            return "\(user!.name!)-\(id!)-\(tagForDownload).jpg"
        }
    }

    private var tagForDownload: String {
        get {
            return "full"
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

    static func createToday() -> UnsplashImage {
        let today = UnsplashImage()
        let urls = ImageUrl()
        let user = UnsplashUser()
        user.userName = "JuniperPhoton"
        user.name = "JuniperPhoton"
        user.id = "JuniperPhoton"

        let df = DateFormatter()
        df.dateFormat = "yyyyMMDD"
        let date = df.string(from: Date())

        urls.raw = "\(Request.AUTO_CHANGE_WALLPAPER)\(date).jpg"
        urls.full = "\(Request.AUTO_CHANGE_WALLPAPER)\(date).jpg"
        urls.regular = "\(Request.AUTO_CHANGE_WALLPAPER_THUMB)\(date).jpg"
        urls.small = "\(Request.AUTO_CHANGE_WALLPAPER_THUMB)\(date).jpg"
        urls.thumb = "\(Request.AUTO_CHANGE_WALLPAPER_THUMB)\(date).jpg"

        today.color = "#ffffff"
        today.id = "TodayImage"
        today.urls = urls
        today.user = user
        today.isUnsplash = false
        return today
    }
}

class ImageUrl {
    var raw: String?
    var full: String?
    var regular: String?
    var small: String?
    var thumb: String?

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
