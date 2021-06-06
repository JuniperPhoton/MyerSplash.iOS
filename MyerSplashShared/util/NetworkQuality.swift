//
//  NetworkQuality.swift
//  MyerSplashShared
//
//  Created by JuniperPhoton on 2020/10/25.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation

public class NetworkQuality {
    public static let sharedInstance = NetworkQuality()
    
    private var downloadRecords = [Int64]()
    private var errorRecords = 0
    
    private(set) var averageDurationMillis: Int64 = 0
    
    private init() {
        // ignored
    }
    
    public func getCurrentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    public func recordDownloadDuration(startMillis: Int64, success: Bool) {
        let duration = Int64((Date().timeIntervalSince1970 * 1000)) - startMillis
        
        downloadRecords.append(duration)
        
        if !success {
            errorRecords = errorRecords + 1
        }
        
        if downloadRecords.count > 10 || errorRecords > 5 {
            averageDurationMillis = downloadRecords.reduce(0, { (result, current) -> Int64 in
               return current + result
            }) / Int64(downloadRecords.count)
            
            downloadRecords.removeAll()
            errorRecords = 0
        }
    }
}
