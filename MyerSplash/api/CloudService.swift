import Foundation
import Alamofire
import SwiftyJSON

class CloudService {
    private static let PAGING_PARAM             = "page"
    private static let PER_PAGE_PARAM           = "per_page"
    private static let DEFAULT_PER_PAGE         = 10
    private static let DEFAULT_HIGHLIGHTS_COUNT = 60

    static func getNewPhotos(page: Int = 1, callback: @escaping ([UnsplashImage]) -> Void) {
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

    static func getHighlights(page: Int = 1, callback: @escaping ([UnsplashImage]) -> Void) {
        var result    = [UnsplashImage]()
        let calendar  = Calendar(identifier: Calendar.Identifier.republicOfChina)
        let startDate = calendar.date(byAdding: Calendar.Component.day,
                                      value: -(page - 1) * DEFAULT_HIGHLIGHTS_COUNT,
                                      to: Date())!

        for i in (0..<DEFAULT_HIGHLIGHTS_COUNT) {
            let date = calendar.date(byAdding: Calendar.Component.day,
                                     value: -i,
                                     to: startDate)!
            result.append(UnsplashImage.create(date))
        }

        callback(result)
    }

    static func getDefaultParams() -> Dictionary<String, Any> {
        return [
            Request.CLIENT_ID_KEY: Request.getClientId(),
            CloudService.PER_PAGE_PARAM: CloudService.DEFAULT_PER_PAGE
        ]
    }
}
