import Foundation
import UIKit

public class FontSizes {
    public static let Small: CGFloat = 12.0
    public static let Normal: CGFloat = 14.0
    public static let Large: CGFloat = 18.0
    
    #if targetEnvironment(macCatalyst)
    public static let contentFontSize = CGFloat(17)
    #else
    public static let contentFontSize = CGFloat(13)
    #endif

    #if targetEnvironment(macCatalyst)
    public static let titleFontSize = CGFloat(25)
    #else
    public static let titleFontSize = CGFloat(17)
    #endif
}
