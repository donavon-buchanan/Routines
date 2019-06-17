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
    dynamic var originalSegment: Int = 0
    dynamic var completeUntil = Date()
    dynamic var repeats: Bool = true
    dynamic var notes: String?
    dynamic var priority: Int = 0

    // For syncing
    dynamic var isDeleted: Bool = false

    required convenience init(title: String, segment: Int, priority _: Int, repeats: Bool, notes: String?) {
        self.init()
        self.title = title
        self.segment = segment
        originalSegment = segment
        self.repeats = repeats
        self.notes = notes

        if Date() >= firstTriggerDate(segment: segment), RoutinesPlus.getShowUpcomingTasks() {
            completeUntil = Date().startOfNextDay
        }
    }

    // Notification identifier
    dynamic var uuidString: String = UUID().uuidString
    override static func primaryKey() -> String? {
        return "uuidString"
    }

    func addNewItem(_ item: Items) {
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        realm.add(item)
                    }
                } catch {
                    fatalError("Error adding new item: \(error)")
                }
            }
        }
        Items.requestNotificationPermission()
        addNewNotification()
    }

    func updateItem(title: String, segment: Int, repeats: Bool, notes: String?, priority: Int) {
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.dateModified = Date()
                        self.title = title
                        self.segment = segment
                        self.originalSegment = segment
                        self.repeats = repeats
                        self.notes = notes
                        self.priority = priority
                    }
                } catch {
                    fatalError("Error updating item: \(error)")
                }
            }
        }
        removeNotification()
        addNewNotification()
    }

    func completeItem() {
        if !repeats {
            softDelete()
        } else {
            printDebug("marking completed until: \(Date().startOfNextDay)")
            DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
                autoreleasepool {
                    let realm = try! Realm()
                    do {
                        try realm.write {
                            self.segment = self.originalSegment
                            self.completeUntil = Date().startOfNextDay
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

    static func batchComplete(itemArray: [Items]) {
        var itemsToComplete: [Items] = []
        var itemsToSoftDelete: [Items] = []
        printDebug(#function)
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                itemArray.forEach { item in
                    if item.repeats {
                        itemsToComplete.append(item)
                    } else {
                        itemsToSoftDelete.append(item)
                    }
                }

                /* It would make sense to make use of the batch delete func
                 But we need to keep this all in the same write commit block
                 */
                let realm = try! Realm()
                do {
                    realm.beginWrite()
                    itemsToSoftDelete.forEach { item in
                        item.isDeleted = true
                    }
                    itemsToComplete.forEach { item in
                        item.segment = item.originalSegment
                        item.completeUntil = Date().startOfNextDay
                        item.dateModified = Date()
                    }
                    try realm.commitWrite()
                } catch {
                    fatalError("\(#function) failed with error: \(error)")
                }
            }
        }
    }

    // MARK: - iCloud Sync

    // Sync soft delete
    func softDelete() {
        printDebug("soft deleting item")
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

    static func batchSoftDelete(itemArray: [Items]) {
        printDebug(#function)
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    realm.beginWrite()
                    itemArray.forEach { item in
                        item.isDeleted = true
                    }
                    try realm.commitWrite()
                } catch {
                    fatalError("\(#function) failed with error: \(error)")
                }
            }
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
                    // TODO: Maybe should match this against "originalSegment"?
                    let items = realm.objects(Items.self).filter("segment >= %@ AND isDeleted = %@ AND completeUntil <= %@", itemSegment, false, item.completeUntil).sorted(byKeyPath: "dateModified").sorted(byKeyPath: "segment")
                    guard let currentItemIndex = items.index(of: item) else { return }
                    printDebug("Item title: \(item.title!) at index: \(currentItemIndex)")
                    badgeCount = currentItemIndex + 1
                    printDebug("setBadgeNumber to \(badgeCount) for \(item.title!)")
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
            center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { _, _ in
                // Enable or disable features based on authorization.
            }
        } else {
            // Fallback on earlier versions
            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                // Enable or disable features based on authorization.
            }
        }
    }

    // Remove notifications for Item
//    func removeNotification(uuidStrings: [String]) {
//        let center = UNUserNotificationCenter.current()
//        center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
//    }

    func removeNotification() {
        printDebug("Removing notification for id: \(uuidString)")
        let uuidStrings: [String] = ["\(uuidString)0", "\(uuidString)1", "\(uuidString)2", "\(uuidString)3", uuidString]

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
    }

    func snooze() {
        removeNotification()

        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.dateModified = Date()
                        self.segment = snoozeTo()
                    }
                } catch {
                    printDebug("failed to snooze item")
                }
            }
            // Little bit redundant. But this hasn't proven to be the most reliable system.
            addNewNotification()
        }
        printDebug("Snoozing to \(segment). Original segment was \(originalSegment)")
        AppDelegate.refreshNotifications()
    }

    fileprivate func snoozeTo() -> Int {
        let segment = Options.getCurrentSegmentFromTime()
        switch segment {
        case 3:
            return 0
        default:
            return segment + 1
        }
    }

    func moveToNextSegment() {
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        switch self.segment {
                        case 3:
                            self.segment = 0
                        default:
                            self.segment += 1
                        }
                    }
                } catch {
                    printDebug("\(#function): \(error)")
                }
            }
        }
    }

    func addNewNotification() {
        let firstDate = firstTriggerDate(segment: segment)

        // Check if notifications are enabled for the segment first
        // Also check if item hasn't been marked as complete already
        if Options.getSegmentNotification(segment: segment), completeUntil < Date().endOfDay, Date() <= firstTriggerDate(segment: segment) {
            createNotification(title: title!, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
            debugPrint("Notification Date: \(firstDate)")
        } else if Options.getSegmentNotification(segment: segment), completeUntil > Date().endOfDay, Date() <= firstTriggerDate(segment: segment) {
            createNotification(title: title!, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
            debugPrint("Notification Date: \(firstDate)")
        } else {
            createNotification(title: title!, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate.nextDay)
            debugPrint("Notification Date: Next Day - \(firstDate.nextDay)")
        }
    }

    func createNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate _: Date) {
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
        // dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: firstDate)
        dateComponents.timeZone = TimeZone.autoupdatingCurrent

        dateComponents.hour = Options.getOptionHour(segment: segment)
        dateComponents.minute = Options.getOptionMinute(segment: segment)

        #if DEBUG
            if repeats {
                debugPrint("Task titled \(title) repeats")
            } else {
                debugPrint("Task titled \(title) does NOT repeat")
            }
        #endif

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)

        // Create the request
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        // Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if error != nil {
                printDebug("Failed to create notification with error: \(String(describing: error))")
            } else {
                printDebug("Notification created successfully")
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

    func setDailyRepeat(_ bool: Bool) {
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.repeats = bool
                    }
                } catch {
                    printDebug("failed to update daily repeat bool")
                }
            }
        }
    }

    func firstTriggerDate(segment: Int) -> Date {
        var segmentTime = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: Date())
        segmentTime.hour = Options.getOptionHour(segment: segment)
        segmentTime.minute = Options.getOptionMinute(segment: segment)
        segmentTime.second = 0

        // The actual day is handled in addNewNotification()
        // The name of this func is now a bit misleading
        printDebug("\(#function) - \(segmentTime.date!)")
        return segmentTime.date!
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
