import Foundation
import UIKit

extension UIFont {
    var bold: UIFont {
        return with(traits: .traitBold)
    }

    var italic: UIFont {
        return with(traits: .traitItalic)
    }

    var boldItalic: UIFont {
        return with(traits: [.traitBold, .traitItalic])
    }
    
    var light: UIFont {
        let descriptor = UIFontDescriptor(name: "Helvetica-Light", size: 0.0)
        return UIFont(descriptor: descriptor, size: 0.0)
    }

    func with(traits: UIFontDescriptor.SymbolicTraits, fontSize: CGFloat = 0.0) -> UIFont {
        var descriptor: UIFontDescriptor!
        
        if (traits == UIFontDescriptor.SymbolicTraits.traitBold) {
            descriptor = UIFontDescriptor(name: "Helvetica-Bold", size: fontSize)
        } else {
            self.fontDescriptor.withSymbolicTraits(traits)
        }
        return UIFont(descriptor: descriptor, size: fontSize)
    }
}
