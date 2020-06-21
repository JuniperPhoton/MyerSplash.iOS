import Foundation
import UIKit

class Dimensions {
    static let ToastHeight: CGFloat = 36
    static let SingleChoiceItemHeight: CGFloat = 50
    static let ImageDetailExtraHeight: CGFloat = 80
    
    static let SmallRoundCornor = 4

    static let TitleMargin = 20

    static let ToastMarginBottom = 30

    static let FabRadius = 50
    static let FabIconSize = 20
    
    static let ShadowOffsetY = 2
    static let ShadowRadius = 4
    static let ShadowOpacity: Float = 0.2
    
    static let MIN_MODE_WIDTH = 400.cgFloat
}

extension Int {
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
    
    var cgFloat: CGFloat {
        get {
            return CGFloat(self)
        }
    }
}
