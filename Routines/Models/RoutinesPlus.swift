//
//  RoutinesPlus.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/12/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import UIKit

@objcMembers class RoutinesPlus: Object {
    static let realmDispatchQueueLabel: String = "background"
    let cloudSyncKey: String = "cloudSync"
//    static let expiryDateKey: String = "expiryDate"

    dynamic var routinesPlusKey = UUID().uuidString
    override static func primaryKey() -> String {
        "routinesPlusKey"
    }

//    dynamic var routinesPlusPurchased: Bool = false
//    dynamic var purchasedProduct: String = ""

    // View upcoming
    dynamic var showUpcomingTasks: Bool = false

    static func getShowUpcomingTasks() -> Bool {
        let realm = try? Realm()
        guard let routinesPlusOptions = realm?.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey()) else { return false }
        return routinesPlusOptions.showUpcomingTasks
    }

    static func setUpcomingTasks(_ isOn: Bool) {
        DispatchQueue(label: RoutinesPlus.realmDispatchQueueLabel).sync {
            autoreleasepool {
                if let realm = try? Realm() {
                    guard let routinesPlusOptions = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey()) else { return }
                    do {
                        try realm.write {
                            routinesPlusOptions.showUpcomingTasks = isOn
                        }
                    } catch {
                        realm.cancelWrite()
                    }
                }
            }
        }
    }
}
