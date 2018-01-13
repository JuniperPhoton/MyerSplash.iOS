import Foundation
import UIKit

extension UIFont {
    var bold: UIFont {
        return with(traits: .traitBold)
    } // bold

    var italic: UIFont {
        return with(traits: .traitItalic)
    } // italic

    var boldItalic: UIFont {
        return with(traits: [.traitBold, .traitItalic])
    } // boldItalic

    func with(traits: UIFontDescriptorSymbolicTraits, fontSize: CGFloat = 0.0) -> UIFont {
        var descriptor: UIFontDescriptor!
        if (traits == UIFontDescriptorSymbolicTraits.traitBold) {
            descriptor = UIFontDescriptor(name: "Helvetica-Bold", size: fontSize)
        } else {
            self.fontDescriptor.withSymbolicTraits(traits)
        }

        return UIFont(descriptor: descriptor, size: fontSize)
    } // with(traits:)
} // extension