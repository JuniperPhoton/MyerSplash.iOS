import Foundation
import UIKit
import Nuke

extension ImageCache {
    static func isCached(urlString: String?) -> Bool {
        guard let url = urlString else {
            return false
        }

        let request = Nuke.ImageRequest(url: URL(string: url)!)
        return ImageCache.shared[request] != nil
    }
}

extension UIView {
    func showToast(_ text: String) {
        ToastView.Builder.init()
                         .attachTo(self)
                         .setMarginBottom(Dimensions.TOAST_MARGIN_BOTTOM)
                         .setText(text)
                         .build()
                         .show()
    }
}
