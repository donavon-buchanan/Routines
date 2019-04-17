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
    static let realmDispatchQueueLabel: String = "background"

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

    func addNewItem(_ item: Items) {
        Items.requestNotificationPermission()
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        realm.add(item, update: true)
                    }
                } catch {
                    fatalError("Error adding new item: \(error)")
                }
            }
        }
        addNewNotification()
    }

    func updateItem(title: String, segment: Int, repeats: Bool, notes: String?) {
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.dateModified = Date()
                        self.title = title
                        self.segment = segment
                        self.repeats = repeats
                        self.notes = notes
                        realm.add(self, update: true)
                    }
                } catch {
                    fatalError("Error updating item: \(error)")
                }
            }
        }
        removeNotification()
        addNewNotification()
    }

//    func completeItem(completeUntil: Date) {
//        if !repeats {
//            softDelete()
//        } else {
//            #if DEBUG
//                print("marking completed until: \(completeUntil)")
//            #endif
//            DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
//                autoreleasepool {
//                    let realm = try! Realm()
//                    do {
//                        try realm.write {
//                            self.completeUntil = completeUntil
//                            self.dateModified = Date()
//                        }
//                    } catch {
//                        // print("failed to save completeUntil")
//                        fatalError("Error completing item: \(error)")
//                    }
//                }
//            }
//        }
//    }

    func completeItem() {
        if !repeats {
            softDelete()
        } else {
            #if DEBUG
                print("marking completed until: \(completeUntil)")
            #endif
            DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
                autoreleasepool {
                    let realm = try! Realm()
                    do {
                        try realm.write {
                            self.completeUntil = self.dateModified.startOfNextDay
                            self.dateModified = Date()
                        }
                    } catch {
                        // print("failed to save completeUntil")
                        fatalError("Error completing item: \(error)")
                    }
                }
            }
        }
        AppDelegate.refreshNotifications()
    }

    // MARK: - iCloud Sync

    // Sync soft delete
    func softDelete() {
        #if DEBUG
            print("soft deleting item")
        #endif
        removeNotification()
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.isDeleted = true
                    }
                } catch {
                    fatalError("Error with softDelete: \(error)")
                }
            }
            // print("softDelete completed")
        }
    }

    // MARK: - Notification Handling

    static func setBadgeNumber(id: String) -> Int {
        var badgeCount = 0
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                // Get all the items in or under the current segment.
                if let item = realm.object(ofType: Items.self, forPrimaryKey: id) {
                    let itemSegment = item.segment
                    // Only count the items who's segment is equal or greater than the current item
                    // TODO: Maybe completeUntil should be compared against item completeUntil instead of endOfDay
                    let items = realm.objects(Items.self).filter("segment >= %@ AND isDeleted = %@ AND completeUntil <= %@", itemSegment, false, item.completeUntil).sorted(byKeyPath: "dateModified").sorted(byKeyPath: "segment")
                    guard let currentItemIndex = items.index(of: item) else { return }
                    #if DEBUG
                        print("Item title: \(item.title!) at index: \(currentItemIndex)")
                    #endif
                    badgeCount = currentItemIndex + 1
                    #if DEBUG
                        print("setBadgeNumber to \(badgeCount) for \(item.title!)")
                    #endif
                }
            }
        }

        return badgeCount
    }

    static func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        // let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds
        if #available(iOS 12.0, *) {
            center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { granted, _ in
                // Enable or disable features based on authorization.
                if granted {
                    // print("App Delegate: App has notification permission")
                } else {
                    // print("App Delegate: App does not have notification permission")
                    return
                }
            }
        } else {
            // Fallback on earlier versions
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                // Enable or disable features based on authorization.
                if granted {
                    // print("App Delegate: App has notification permission")
                } else {
                    // print("App Delegate: App does not have notification permission")
                    return
                }
            }
        }
    }

    // Remove notifications for Item
    func removeNotification(uuidStrings: [String]) {
        // print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
        // center.removeDeliveredNotifications(withIdentifiers: uuidStrings)
    }

    func removeNotification() {
        #if DEBUG
            print("Removing notification for id: \(uuidString)")
        #endif
        let uuidStrings: [String] = ["\(uuidString)0", "\(uuidString)1", "\(uuidString)2", "\(uuidString)3", uuidString]
        // print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
        // center.removeDeliveredNotifications(withIdentifiers: uuidStrings)
    }

    func snooze() {
        removeNotification()

        // print("running deleteItem")
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.segment = snoozeTo()
                    }
                } catch {
                    // print("failed to snooze item")
                }
            }
            addNewNotification()
            // print("snooze completed successfully")
        }
        AppDelegate.refreshNotifications()
    }

    fileprivate func snoozeTo() -> Int {
        switch segment {
        case 3:
            return 0
        default:
            return segment + 1
        }
    }

    func addNewNotification() {
        let firstDate = firstTriggerDate(segment: segment)

        // Check if notifications are enabled for the segment first
        // Also check if item hasn't been marked as complete already
        if Options.getSegmentNotification(segment: segment), completeUntil < Date().endOfDay {
            createNotification(title: title!, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
        }
    }

    func createNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
        // print("createNotification running")
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.threadIdentifier = String(getItemSegment(id: uuidString))

        content.badge = NSNumber(integerLiteral: Items.setBadgeNumber(id: uuidString))

        if let notesText = notes {
            content.body = notesText
        }

        // Assign the category (and the associated actions).
        switch segment {
        case 1:
            content.categoryIdentifier = "afternoon"
        case 2:
            content.categoryIdentifier = "evening"
        case 3:
            content.categoryIdentifier = "night"
        default:
            content.categoryIdentifier = "morning"
        }

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        // Keep notifications from occurring too early for tasks created for tomorrow
        if firstDate > Date() {
            // print("Notification set to tomorrow")
            dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: firstDate)
        }
        dateComponents.timeZone = TimeZone.autoupdatingCurrent

        dateComponents.hour = Options.getOptionHour(segment: segment)
        dateComponents.minute = Options.getOptionMinute(segment: segment)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)

        // Create the request
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        // Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if error != nil {
                #if DEBUG
                    print("Failed to create notification with error: \(String(describing: error))")
                #endif
            } else {
                #if DEBUG
                    print("Notification created successfully")
                #endif
            }
        }
    }

    func getItemSegment(id: String) -> Int {
        var identifier: String {
            if id.count > 36 {
                return String(id.dropLast())
            } else {
                return id
            }
        }
        var segment = Int()
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let item = realm.object(ofType: Items.self, forPrimaryKey: identifier) {
                    segment = item.segment
                }
            }
        }
        return segment
    }

//    static func updateAppBadgeCount() {
//        if Options.getBadgeOption() {
//            // print("updating app badge number")
//            DispatchQueue(label: realmDispatchQueueLabel).sync {
//                autoreleasepool {
//                    let realm = try! Realm()
//                    let badgeCount = realm.objects(Items.self).filter("dateModified < %@ AND isDeleted = \(false) AND completeUntil < %@", Date(), Date()).count
//                    DispatchQueue.main.async {
//                        autoreleasepool {
//                            UIApplication.shared.applicationIconBadgeNumber = badgeCount
//                        }
//                    }
//                }
//            }
//        } else {
//            UIApplication.shared.applicationIconBadgeNumber = 0
//        }
//    }

    func setDailyRepeat(_ bool: Bool) {
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.repeats = bool
                    }
                } catch {
                    // print("failed to update daily repeat bool")
                }
            }
        }
    }

    func firstTriggerDate(segment: Int) -> Date {
        let tomorrow = Date().startOfNextDay
        var dateComponents = DateComponents()
        var segmentTime = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: Date())
        segmentTime.hour = Options.getOptionHour(segment: segment)
        segmentTime.minute = Options.getOptionMinute(segment: segment)
        segmentTime.second = 0
        // TODO: This might cause problems
        if Date() > segmentTime.date! {
            // print("Setting item date for tomorrow")
            dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: tomorrow)
        } else {
            // print("Setting item date for today")
            dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: Date())
        }
        dateComponents.hour = Options.getOptionHour(segment: segment)
        dateComponents.minute = Options.getOptionMinute(segment: segment)
        dateComponents.second = 0
        // print("Setting first trigger date for: \(dateComponents)")
        return dateComponents.date!
    }

    static func getCountForSegment(segment: Int) -> Int {
        var count = Int()
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Items.self).filter("segment = \(segment)").count
            }
        }
        return count
    }

    static func getItemCount() -> Int {
        var count = Int()
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Items.self).count
            }
        }
        return count
    }
}

extension Items: CKRecordConvertible {
    // Yep, leave it blank!
}

extension Items: CKRecordRecoverable {
    // Leave it blank, too.
}
