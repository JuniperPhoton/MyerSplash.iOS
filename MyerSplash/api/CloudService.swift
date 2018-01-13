import Foundation
import Alamofire
import SwiftyJSON

class CloudService {
    private static let PAGING_PARAM = "page"
    private static let PER_PAGE_PARAM = "per_page"
    private static let DEFAULT_PER_PAGE = 10

    static func getNewPhotos(page: Int = 0, callback: @escaping ([UnsplashImage]) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        var params = getDefaultParams()
        params[CloudService.PAGING_PARAM] = page

        Alamofire.request(Request.PHOTO_URL, parameters: params).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let array = json.flatMap { s, json -> UnsplashImage? in
                    UnsplashImage(json)
                }
                callback(array)
            case .failure(let error):
                print(error)
            }
        }
    }

    static func getDefaultParams() -> Dictionary<String, Any> {
        return [
            Request.CLIENT_ID_KEY: Request.CLIENT_ID,
            CloudService.PER_PAGE_PARAM: CloudService.DEFAULT_PER_PAGE
        ]
    }
}
