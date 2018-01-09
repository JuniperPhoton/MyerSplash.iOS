import Foundation
import Alamofire
import SwiftyJSON

class CloudService {
    static func getNewPhotos(page: Int = 0, callback: @escaping ([UnsplashImage]) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        var params = getDefaultParams()
        params["page"] = page

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
            "per_page": 10
        ]
    }
}
