import Foundation
import UIKit

class Dimensions {
    static let TOAST_HEIGHT: CGFloat = 36
    static let SETTING_ITEM_HEIGHT: CGFloat = 50
    static let SINGLE_CHOICE_OPTION_HEIGHT: CGFloat = 50
    static let FAB_SIZE: CGFloat = 70
    static let NAVIGATION_VIEW_HEIGHT: CGFloat = 100
    static let NAVIGATION_ICON_SIZE: CGFloat = 50
    static let IMAGE_DETAIL_EXTRA_HEIGHT: CGFloat = 80
    static let DUMMY_HEADER_HEIGHT: CGFloat = 80
    
    static let SMALL_ROUND_CORNOR = 4

    static let TOP_NAVIGATION_BAR_HEIGHT: CGFloat = 50

    static let TITLE_MARGIN = 20

    static let TOAST_MARGIN_BOTTOM = 30

    static let FAB_RADIUS = 50
    static let FAB_ICON_SIZE = 20
}

extension Int {
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}
