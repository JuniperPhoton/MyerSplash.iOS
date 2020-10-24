import Foundation
import UIKit
import SwiftyJSON
import WCDBSwift
import AVFoundation.AVUtilities

public class UnsplashImage: ColumnJSONCodable {
    public private (set) var id: String?
    public private (set) var color: String?
    public private (set) var likes: Int = 0
    public private (set) var width: Int = 0
    public private (set) var height: Int = 0
    public private (set) var urls: ImageUrl?
    public private (set) var user: UnsplashUser?
    public private (set) var sponsorship: Sponsorship?
    public private (set) var isUnsplash = true
    
    enum CodingKeys: String, CodingKey {
        case id, color, likes, width, height, urls, user, sponsorship
    }
    
    public var rawAspectRatioF: CGFloat {
        get {
            if width == 0 || height == 0 {
                return CGFloat(1.5)
            } else {
                return CGFloat(width) / CGFloat(height)
            }
        }
    }

    public var fileNameForDownload: String {
        get {
            return "\(user!.name!) - \(id!) - \(tagForDownload)"
        }
    }

    public var themeColor: UIColor {
        get {
            return color != nil ? UIColor(color!) : UIColor.black
        }
    }

    public var userName: String? {
        get {
            return user?.name
        }
    }

    public var userHomePage: String? {
        get {
            return user?.homeUrl
        }
    }

    public var listUrl: String? {
        get {
            let averageDuration = NetworkQuality.sharedInstance.averageDurationMillis
            
            if averageDuration > 1000 {
                return urls?.small
            } else if averageDuration > 2000 {
                return urls?.thumb
            } else {
                return urls?.regular
            }
        }
    }

    public var downloadUrl: String? {
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

    public var fileName: String {
        get {
            let id = self.id ?? "id"
            return "\(id)-\(tagForDownload).jpeg"
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
}

// MARK: Aspect ratio
public extension UnsplashImage {
    func getAspectRatioF(viewWidth: CGFloat, viewHeight: CGFloat)-> CGFloat {
        let rect = getTargetRect(viewWidth: viewWidth, viewHeight: viewHeight)
        return rect.width / rect.height
    }

    func getTargetRect(viewWidth: CGFloat, viewHeight: CGFloat)-> CGRect {
        let rawRatio: CGFloat
        if width == 0 || height == 0 {
            rawRatio = 3.0 / 2.0
        } else {
            rawRatio = CGFloat(width) / CGFloat(height)
        }

        let fixedInfoHeight = Dimensions.ImageDetailExtraHeight

        let decorViewWidth = viewWidth
        let decorViewHeight = viewHeight

        let fixedHorizontalMargin: CGFloat
        let fixedVerticalMargin: CGFloat

        if UIDevice.current.userInterfaceIdiom == .pad {
            fixedHorizontalMargin = 50
            fixedVerticalMargin = 70
        } else {
            fixedHorizontalMargin = 0
            fixedVerticalMargin = 0
        }

        return AVMakeRect(aspectRatio: CGSize(width: rawRatio, height: 1.0),
                              insideRect: CGRect(x: fixedHorizontalMargin, y: fixedVerticalMargin,
                                                 width: decorViewWidth - fixedHorizontalMargin * 2,
                                                 height: decorViewHeight - fixedVerticalMargin * 2 - fixedInfoHeight))
    }

    func getAspectRatio(viewWidth: CGFloat, viewHeight: CGFloat)-> String {
        let rect = getTargetRect(viewWidth: viewWidth, viewHeight: viewHeight)
        return "\(rect.width):\(rect.height)"
    }
}

// MARK: Today image
extension UnsplashImage {
    private static var createdImageCount = 0

    public static func isToday(_ image: UnsplashImage) -> Bool {
        return image.id == createDateString(Date())
    }

    public static func createTodayImageId() -> String {
        return createTodayImageDateString()
    }

    public static func createTodayImageDateString() -> String {
        return createDateString(Date())
    }

    public static func createDateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        return df.string(from: date)
    }
    
    public static func create(_ date: Date) -> UnsplashImage {
        let image = UnsplashImage()
        let urls = ImageUrl()
        let user = UnsplashUser()
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

        image.color = createdImageCount % 2 == 0 ? "#ffffff" : "#e2e2e2"
        image.id = dateStr
        image.urls = urls
        image.user = user
        image.isUnsplash = false
        image.width = 3
        image.height = 2

        createdImageCount += 1

        return image
    }

    public static func createToday() -> UnsplashImage {
        return create(Date())
    }
}

public class ImageUrl: ColumnJSONCodable {
    var raw: String?
    var full: String?
    var regular: String?
    var small: String?
    var thumb: String?
}

public extension String {
    func getScaled(maxWidth: Int, quality: Int = 75) -> String? {
        guard var components = URLComponents(string: self) else {
            return self
        }
                
        components.replaceQuery(name: "w", value: String(maxWidth))
        components.replaceQuery(name: "q", value: String(quality))
        
        return components.url?.absoluteString
    }
}

extension URLComponents {
    mutating func replaceQuery(name: String, value: String) {
        let item = URLQueryItem(name: name, value: value)
        
        let originalWidthQuery = self.queryItems?.firstIndex(where: { $0.name == name } ) ?? -1
        if originalWidthQuery > 0 {
            self.queryItems?[originalWidthQuery] = item
        } else {
            self.queryItems?.append(item)
        }
    }
}

public class Sponsorship: ColumnJSONCodable {
    // empty class
}
