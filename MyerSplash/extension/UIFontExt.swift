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
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
            return self
        } // guard
        return UIFont(descriptor: descriptor, size: fontSize)
    } // with(traits:)
} // extension