//
//  ImageRepo.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/5.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation

protocol Callback {
    func onNewImages(_ list: [UnsplashImage])
    func onFailed(_ e: Error?)
}

class ImageRepo {
    var title: String = ""
    
    func loadImages(_ page: Int, callback: Callback) {
        
    }
}

class HighlightsImageRepo: ImageRepo {
    override var title: String {
        get {
            return "HIGHLIGHTS"
        }
        set {
            
        }
    }
    
    override func loadImages(_ page: Int, callback: Callback) {
        
    }
}

class NewImageRepo: ImageRepo {
    override var title: String {
        get {
            return "NEW"
        }
        set {
            
        }
    }
    
    override func loadImages(_ page: Int, callback: Callback) {
        
    }
}

class RandomImageRepo: ImageRepo {
    override var title: String {
        get {
            return "RANDOM"
        }
        set {
            
        }
    }
    
    override func loadImages(_ page: Int, callback: Callback) {
        
    }
}

class DeveloperImageRepo: ImageRepo {
    override var title: String {
        get {
            return "DEVELOPER"
        }
        set {
            
        }
    }
    
    override func loadImages(_ page: Int, callback: Callback) {
        
    }
}

class SearchImageRepo: ImageRepo {
    override var title: String {
        get {
            return "SEARCH"
        }
        set {
            
        }
    }
    
    override func loadImages(_ page: Int, callback: Callback) {
        
    }
}
