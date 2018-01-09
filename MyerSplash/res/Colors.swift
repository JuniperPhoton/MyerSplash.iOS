import Foundation
import UIKit

class Colors {
    static let ThemeColor = "#18c3d8"
    static let ThemeDarkColor = "159c9c"
}

extension String {
    func asUIColor() -> UIColor {
        return UIColor(self)
    }

    func asCGColor() -> CGColor {
        return asUIColor().cgColor
    }
}