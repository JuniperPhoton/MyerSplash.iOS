import Foundation
import UIKit

public class Dimensions {
    public static let SingleChoiceItemHeight: CGFloat = 50
    
    #if targetEnvironment(macCatalyst)
    public static let ToastHeight: CGFloat = 44
    public static let ImageDetailExtraHeight: CGFloat = 110
    public static let DownloadButtonWidth = 120
    #else
    public static let ToastHeight: CGFloat = 36
    public static let ImageDetailExtraHeight: CGFloat = 80
    public static let DownloadButtonWidth = 100
    #endif
    
    public static let SmallRoundCornor = 6

    public static let TitleMargin = 20

    public static let ToastMarginBottom = 30

    public static let FabRadius = 50
    public static let FabIconSize = 20
    
    public static let ShadowOffsetY = 2
    public static let ShadowRadius = 4
    public static let ShadowOpacity: Float = 0.2
        
    public static var ImagesViewSpace: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 18
        } else {
            return 12
        }
    }()
    
    public static let MIN_MODE_WIDTH = 400.cgFloat
}

public extension Int {
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
    
    var cgFloat: CGFloat {
        get {
            return CGFloat(self)
        }
    }
}
