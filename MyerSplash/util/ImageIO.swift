//
// Created by MAC on 2020/1/6.
// Copyright (c) 2020 juniper. All rights reserved.
//

import Foundation
import Nuke

class ImageIO {
    static func loadImage(url: String, intoView: ImageDisplayingView) {
        let request = ImageRequest(url: URL(string: url)!)
        loadImage(request: request, intoView: intoView)
    }
    
    static func loadImage(request: ImageRequest, intoView: ImageDisplayingView) {
        Nuke.loadImage(with: request,
                       options: ImageLoadingOptions(
                            placeholder: nil,
                            transition: .fadeIn(duration: 0.3),
                            failureImage: nil,
                            failureImageTransition: nil,
                            contentModes: .init(success: .scaleAspectFill, failure: .center, placeholder: .center)),
                       into: intoView, progress: nil, completion: nil)
    }
}
