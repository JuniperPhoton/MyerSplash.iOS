import Foundation
import SwiftyJSON

class UnsplashUser {
    var id: String?
    var userName: String?
    var name: String?
    var links: ProfileUrl?

    var homeUrl: String? {
        get {
            return links?.html
        }
    }

    init() {
    }

    init(_ json: JSON) {
        id = json["id"].string
        userName = json["userName"].string
        name = json["name"].string

        let linksJson = json["links"]
        links = ProfileUrl(linksJson)
    }
}

class ProfileUrl {
    var selfUrl: String?
    var html: String?
    var photos: String?
    var likes: String?
    var portfolio: String?

    init() {
    }

    init(_ json: JSON) {
        selfUrl = json["self"].string
        html = json["html"].string
        photos = json["photos"].string
        likes = json["likes"].string
        portfolio = json["portfolio"].string
    }
}