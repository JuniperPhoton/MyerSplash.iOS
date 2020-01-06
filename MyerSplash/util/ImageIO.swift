//
// Created by MAC on 2020/1/6.
// Copyright (c) 2020 juniper. All rights reserved.
//

import Foundation
import Nuke

class ImageIO {
    static func loadImage(url: String, intoView: ImageDisplayingView, withAnimation: Bool = true) {
        Nuke.loadImage(with: URL(string: url)!,
                options: ImageLoadingOptions(
                        placeholder: nil,
                        transition: .fadeIn(duration: 0.3),
                        failureImage: nil,
                        failureImageTransition: nil,
                        contentModes: .init(success: .scaleAspectFill, failure: .center, placeholder: .center)),
                into: intoView)
    }
}