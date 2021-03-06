//
//  AppDb.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/8.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import WCDBSwift

public class AppDb {
    private static let DB_PATH = "app_db/appdb"
    private static let DOWNLOADS_TABLE = "downloads_table"

    public static let instance = AppDb()

    private var db: Database {
        let documentsURL
                = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(AppDb.DB_PATH)
        return Database.init(withFileURL: fileURL)
    }

    private init() {
        checkFirst()
    }

    private func checkFirst() {
        if (try? db.isTableExists(AppDb.DOWNLOADS_TABLE)) != true {
            try? db.create(table: AppDb.DOWNLOADS_TABLE, of: DownloadItem.self)
        }
    }
    
    public func updateItemsToFailed() {
        do {
            try db.update(table: AppDb.DOWNLOADS_TABLE,
                          on: [DownloadItem.Properties.status],
                          with: [DownloadStatus.Failed.rawValue],
                          where: DownloadItem.Properties.status == DownloadStatus.Downloading.rawValue,
                          orderBy: nil, limit: nil, offset: nil)
        } catch {
            // do nothing
        }
    }

    public func insertToDb(_ item: DownloadItem) {
        do {
            try db.insert(objects: item, intoTable: AppDb.DOWNLOADS_TABLE)
        } catch {
            // do nothing
        }
    }

    public func insertOrReplace(_ item: DownloadItem) {
        do {
            try db.insertOrReplace(objects: item, intoTable: AppDb.DOWNLOADS_TABLE)
        } catch {
            // do nothing
        }
    }

    public func deleteAll() {
        do {
            try db.delete(fromTable: AppDb.DOWNLOADS_TABLE)
        } catch {
            // do nothing
        }
    }

    public func queryItemById(id: String) -> DownloadItem? {
        return try? db.getObject(on: DownloadItem.Properties.all,
                fromTable: AppDb.DOWNLOADS_TABLE,
                where: DownloadItem.CodingKeys.id == id)
    }

    public func getAllItems() -> [DownloadItem] {
        return (try? db.getObjects(on: DownloadItem.Properties.all,
                fromTable: AppDb.DOWNLOADS_TABLE,
                orderBy: [DownloadItem.Properties.createTime.asOrder(by: .descending)])) ?? [DownloadItem]()
    }
}
