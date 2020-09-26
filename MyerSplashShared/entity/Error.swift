//
//  Error.swift
//  MyerSplashShared
//
//  Created by JuniperPhoton on 2020/9/26.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation

public struct NotImplError: Error {
    public init() {
        
    }
}

public struct ApiError: Error {
    let message: String?
    
    public init(message: String?) {
        self.message = message
    }
}
