import Foundation
import UIKit
import MyerSplashExtensions

public class Colors {
    public static let THEME = "#18c3d8"
    public static let THEME_DARK = "#159c9c"
    public static let BACKGROUND = "#000000"
    public static let DIALOG_MASK = "#b2000000"
}

public extension String {
    func asUIColor() -> UIColor {
        return UIColor(self)
    }

    func asCGColor() -> CGColor {
        return asUIColor().cgColor
    }
}
