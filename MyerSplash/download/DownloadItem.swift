//
// Created by MAC on 2020/1/8.
// Copyright (c) 2020 juniper. All rights reserved.
//

import Foundation
import WCDBSwift

enum DownloadStatus: Int {
    case Pending = -1
    case Downloading = 0
    case Success = 1
    case Failed = 2
}

class DownloadItem: TableCodable {
    var id: String? = nil
    var unsplashImage: UnsplashImage? = nil
    var progress: Float = 0
    var fileURL: String? = nil
    var status: Int = DownloadStatus.Pending.rawValue
    var createTime: Int64 = Int64(Date().timeIntervalSinceReferenceDate)

    enum CodingKeys: String, CodingTableKey {
        typealias Root = DownloadItem
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case id
        case unsplashImage
        case progress
        case fileURL
        case status
        case createTime

        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true),
                unsplashImage: ColumnConstraintBinding(isNotNull: false, defaultTo: nil),
                progress: ColumnConstraintBinding(),
                fileURL: ColumnConstraintBinding(),
                status: ColumnConstraintBinding(),
                createTime: ColumnConstraintBinding()
            ]
        }
    }
}
