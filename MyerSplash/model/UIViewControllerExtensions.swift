//
//  UIViewControllerExtensions.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/10.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentEdit(image: UnsplashImage) {
        let vc = ImageEditViewController(image: image)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
