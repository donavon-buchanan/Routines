//
//  RoutinesPlus.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/12/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation
import IceCream
import RealmSwift

@objcMembers class RoutinesPlus: Object {
    static let realmDispatchQueueLabel: String = "background"
    static let cloudSyncKey: String = "cloudSync"
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
        let realm = try! Realm()
        guard let routinesPlusOptions = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey()) else { return false }
        return routinesPlusOptions.showUpcomingTasks
    }

    static func setUpcomingTasks(_ isOn: Bool) {
        DispatchQueue(label: RoutinesPlus.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                guard let routinesPlusOptions = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey()) else { return }
                do {
                    try realm.write {
                        routinesPlusOptions.showUpcomingTasks = isOn
                    }
                } catch {
                    fatalError("\(#function) error: \(error)")
                }
            }
        }
    }

    static func getCloudSync() -> Bool {
        #if targetEnvironment(simulator) || DEBUG
            return true
        #else
            return UserDefaults.standard.bool(forKey: cloudSyncKey)
        #endif
    }

    static func setCloudSync(toggle: Bool) {
        UserDefaults.standard.set(toggle, forKey: cloudSyncKey)

        AppDelegate.setSync()
    }

//    static func setExpiryDate(date: Date) {
//        printDebug("Setting Routines Plus expiration date to: \(date)")
//        UserDefaults.standard.set(date, forKey: expiryDateKey)
//    }

//    static func getExpiryDate() -> Date {
//        (UserDefaults.standard.object(forKey: expiryDateKey) as? Date) ?? Date()
//    }

//    static func getPurchasedStatus() -> Bool {
//        var status = false
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
//                status = routinesPlus?.routinesPlusPurchased ?? false
//            }
//        }
//        #if targetEnvironment(simulator) || DEBUG
//            return true
//        #else
//            return status
//        #endif
//    }
//
//    static func setPurchasedStatus(status: Bool) {
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
//                do {
//                    try realm.write {
//                        routinesPlus?.routinesPlusPurchased = status
//                    }
//                } catch {
//                    fatalError("\(#function) - Failed to set purchased status in routinesPlus with error: \(error)")
//                }
//            }
//        }
//    }

//    static func setPurchasedProduct(productID: String) {
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
//                do {
//                    try realm.write {
//                        routinesPlus?.purchasedProduct = productID
//                    }
//                } catch {
//                    fatalError("\(#function) - Error saving purchased product: \(error)")
//                }
//            }
//        }
//    }
//
//    static func getPurchasedProduct() -> String {
//        let realm = try! Realm()
//        let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
//        #if targetEnvironment(simulator) || DEBUG
//            return ""
//        #else
//            return routinesPlus?.purchasedProduct ?? ""
//        #endif
//    }
}

extension RoutinesPlus: CKRecordConvertible {
    var isDeleted: Bool {
        false
    }

    // Yep, leave it blank!
}

extension RoutinesPlus: CKRecordRecoverable {
    // Leave it blank, too.
}
