import Foundation
import UIKit

class FontSizes {
    static let Small: CGFloat = 12.0
    static let Normal: CGFloat = 14.0
    static let Large: CGFloat = 18.0
    
    #if targetEnvironment(macCatalyst)
    static let contentFontSize = CGFloat(17)
    #else
    static let contentFontSize = CGFloat(13)
    #endif

    #if targetEnvironment(macCatalyst)
    static let titleFontSize = CGFloat(25)
    #else
    static let titleFontSize = CGFloat(17)
    #endif
}
