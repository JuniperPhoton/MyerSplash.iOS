import Foundation
import UIKit

class Colors {
    static let THEME = "#18c3d8"
    static let THEME_DARK = "#159c9c"
    static let BACKGROUND = "#000000"
    static let DIALOG_MASK = "#b2000000"
}

extension String {
    func asUIColor() -> UIColor {
        return UIColor(self)
    }

    func asCGColor() -> CGColor {
        return asUIColor().cgColor
    }
}