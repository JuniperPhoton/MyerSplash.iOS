//
// Created by MAC on 2020/1/6.
// Copyright (c) 2020 juniper. All rights reserved.
//

import Foundation
import Nuke

class ImageIO {
    private static let TAG = "ImageIO"
    
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
    
    static func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
        let exist = FileManager.default.fileExists(atPath: url.path)
        
        Log.info(tag: ImageIO.TAG, "resizedImage check exists, \(exist) at \(url.path)")

        guard let image = UIImage(contentsOfFile: url.path) else {
            Log.info(tag: ImageIO.TAG, "resizedImage nil image")
            return nil
        }

        Log.info(tag: ImageIO.TAG, "resizedImage about to draw in \(size)")
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
