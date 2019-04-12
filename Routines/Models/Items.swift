//
//  Items.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import IceCream
import RealmSwift
import UserNotifications

// TODO: Figure out inits with Realm
// TODO: Rename this. Shouldn't be plural. But causes realm migration complication.

@objcMembers class Items: Object {
    let realmDispatchQueueLabel: String = "background"

    dynamic var title: String?
    dynamic var dateModified = Date()
    dynamic var segment: Int = 0
    dynamic var completeUntil = Date()
    dynamic var repeats: Bool = true
    dynamic var notes: String?

    // For syncing
    dynamic var isDeleted: Bool = false

    // Notification identifier
    dynamic var uuidString: String = UUID().uuidString
    override static func primaryKey() -> String? {
        return "uuidString"
    }

    func completeItem() {}

    // MARK: - iCloud Sync

    // Sync soft delete
    func softDelete() {
        removeNotification(uuidStrings: ["\(uuidString)0", "\(uuidString)1", "\(uuidString)2", "\(uuidString)3", uuidString])
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.isDeleted = true
                    }
                } catch {
                    print("softDelete failed")
                }
            }
            print("softDelete completed")
        }
    }

    // MARK: - Notification Handling

    // Remove notifications for Item
    func removeNotification(uuidStrings: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
        center.removeDeliveredNotifications(withIdentifiers: uuidStrings)
    }

    func snooze() {
        removeNotification(uuidStrings: ["\(uuidString)0", "\(uuidString)1", "\(uuidString)2", "\(uuidString)3", uuidString])

        print("running deleteItem")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.segment = snoozeTo()
                    }
                } catch {
                    print("failed to snooze item")
                }
            }
            createNotification()
            print("snooze completed successfully")
        }

        AppDelegate().updateAppBadgeCount()
    }

    fileprivate func snoozeTo() -> Int {
        switch segment {
        case 3:
            return 0
        default:
            return segment + 1
        }
    }

    func createNotification() {
        // TODO: Create notification when task is added
    }
}

extension Items: CKRecordConvertible {
    // Yep, leave it blank!
}

extension Items: CKRecordRecoverable {
    // Leave it blank, too.
}
