import Foundation
import SwiftyJSON
import WCDBSwift

public class UnsplashUser: ColumnJSONCodable {
    public internal (set) var id: String?
    public internal (set) var userName: String?
    public internal (set) var name: String?
    public internal (set) var links: ProfileUrl?

    public var homeUrl: String? {
        get {
            return links?.html
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, userName = "username", name, links
    }
}

public class ProfileUrl: ColumnJSONCodable {
    var selfUrl: String?
    var html: String?
    var photos: String?
    var likes: String?
    var portfolio: String?
}
