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
    dynamic var dateModified: Date?
    dynamic var segment: Int = 0
    dynamic var snoozeUntil: Date?
    dynamic var repeats: Bool = false
    dynamic var disableAutoSnooze: Bool = false
    dynamic var notes: String?

    // For syncing
    dynamic var isDeleted: Bool = false

    // Repeats
    dynamic var repeatStyle = "none"
    var daysToRepeat = List<String>()

    // Notification identifier
    dynamic var uuidString: String = UUID().uuidString
    override static func primaryKey() -> String? {
        return "uuidString"
    }

    func setRepeat(style: String) {
        repeats = true
        repeatStyle = style
        // TODO: Just build a check in the view and the auto snooze func to check if repeat is enabled. Ignore if so. But don't actually change the value here.
        print("Repeat has been set.")
    }

    func repeatDaily(sunday: Bool, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool) {
        let days = List<String>()
        if sunday {
            days.append("sunday")
        }
        if monday {
            days.append("monday")
        }
        if tuesday {
            days.append("tuesday")
        }
        if wednesday {
            days.append("wednesday")
        }
        if thursday {
            days.append("thursday")
        }
        if friday {
            days.append("friday")
        }
        if saturday {
            days.append("saturday")
        }
        daysToRepeat = days
        setRepeat(style: "daily")
    }
}

extension Items: CKRecordConvertible {
    // Yep, leave it blank!
}

extension Items: CKRecordRecoverable {
    // Leave it blank, too.
}

extension Items {
    // Sync removal first
    func syncDelete() {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.isDeleted = true
                    }
                } catch {
                    print("syncDelete failed")
                }
            }
            print("syncDelete completed")
        }
    }

    // Handle removal and notifications
    func removeNotification(uuidStrings: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
    }

    // TODO: Clean this up more with local references
//    func deleteItem() {
//        let itemID = uuidString
//        // Add suffix back to uuidString
//        removeNotification(uuidStrings: ["\(itemID)0", "\(itemID)1", "\(itemID)2", "\(itemID)3", itemID])
//
//        print("running deleteItem")
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                do {
//                    try realm.write {
//                        self.isDeleted = true
//                        realm.delete(self)
//                    }
//                } catch {
//                    print("failed to remove delete")
//                }
//            }
//            print("deleteItem completed")
//        }
//
//        // OptionsTableViewController().refreshNotifications()
//        AppDelegate().updateAppBadgeCount()
//    }

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
            print("snooze completed successfully")
        }

        // OptionsTableViewController().refreshNotifications()
        AppDelegate().refreshNotifications()
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

    fileprivate func createNotification() {
        // TODO: Create notification when task is added
        // Reminder notifications will need to be handled elsewhere
    }
}
