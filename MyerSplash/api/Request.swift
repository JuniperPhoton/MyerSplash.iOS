import Foundation
import UIKit

class Request {
    static let BASE_URL = "https://api.unsplash.com/"
    static let PHOTO_URL = "https://api.unsplash.com/photos?"
    static let FEATURED_PHOTO_URL = "https://api.unsplash.com/collections/featured?"
    static let RANDOM_PHOTOS_URL = "https://api.unsplash.com/photos/random?"
    static let DEVELOPER_PHOTOS_URL = "https://api.unsplash.com/users/juniperphoton/photos?"
    static let SEARCH_URL = "https://api.unsplash.com/search/photos?"

    static let AUTO_CHANGE_WALLPAPER = "https://juniperphoton.net/myersplash/wallpapers/"
    static let AUTO_CHANGE_WALLPAPER_THUMB = "https://juniperphoton.net/myersplash/wallpapers/thumbs/"

    static let ME_HOME_PAGE = "https://unsplash.com/@juniperphoton"
    
    private static let PAGING_PARAM = "page"
    private static let PER_PAGE_PARAM = "per_page"
    private static let DEFAULT_PER_PAGE = 10
    private static let DEFAULT_HIGHLIGHTS_COUNT = 60
    private static let CLIENT_ID_KEY = "client_id"

    static func getDefaultParams(paging: Int) -> Dictionary<String, Any> {
        var dic = [
            CLIENT_ID_KEY: AppKeys.getClientId(),
            Request.PAGING_PARAM: paging
            ] as [String : Any]
        
        dic[Request.PER_PAGE_PARAM] = UIDevice.current.userInterfaceIdiom == .pad ? 30 : Request.DEFAULT_PER_PAGE

        return dic
    }
}
