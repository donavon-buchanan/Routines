//
//  NotificationHandler.swift
//  Routines
//
//  Created by Donavon Buchanan on 7/6/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications

struct NotificationHandler {
    let center = UNUserNotificationCenter.current()

    func firstTriggerDate(forItem item: Task) -> Date {
        var segmentTime = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: Date())

        segmentTime.hour = Options.getOptionHour(segment: item.segment)
        segmentTime.minute = Options.getOptionMinute(segment: item.segment)
        segmentTime.second = 0

        // First, check if notifications are enabled for the segment
        // Also check if item hasn't been marked as complete already
        if Options.getSegmentNotification(segment: item.segment), item.completeUntil < Date().endOfDay, Date() <= segmentTime.date! {
            return segmentTime.date!
        } else if Options.getSegmentNotification(segment: item.segment), item.completeUntil > Date().endOfDay, Date() <= segmentTime.date! {
            return segmentTime.date!
        } else {
            return segmentTime.date!.nextDay
        }

        // return segmentTime.date!
    }

    func setBadgeNumber(id: String) -> Int {
        var badgeCount = 0
        let realm = try! Realm()
        // Get all the items in or under the current segment.
        if let item = realm.object(ofType: Task.self, forPrimaryKey: id) {
            let itemSegment = item.segment
            // Only count the items who's segment is equal or greater than the current item
            // TODO: Maybe should match this against "originalSegment"?
            let items = TaskCategory.returnTaskCategory(CategorySelections.All.rawValue).taskList.filter("segment >= %@ AND isDeleted = %@ AND completeUntil <= %@", itemSegment, false, item.completeUntil)//.sorted(byKeyPath: "dateModified").sorted(byKeyPath: "segment")
            if let currentItemIndex = items.index(of: item) {
                debugPrint("Item title: \(item.title!) at index: \(currentItemIndex)")
                badgeCount = currentItemIndex + 1
                debugPrint("setBadgeNumber to \(badgeCount) for \(item.title!)")
            }
        }

        return badgeCount
    }

    func createNewNotification(forItem item: Task, function: String = #function) {
        debugPrint(#function + "Called by \(function)")
        checkNotificationPermission()

        let title = item.title!
        let notes = item.notes
        let segment = item.segment
        let id = item.uuidString
        // let triggerDate = firstTriggerDate(forItem: item)
        // let repeats = item.repeats

        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.threadIdentifier = String(segment)

        content.badge = NSNumber(integerLiteral: setBadgeNumber(id: id))

        if let notes = notes {
            content.body = notes
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

        // let triggerDateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second, .calendar], from: triggerDate)

        let trigger = returnNotificationTrigger(item: item)

        // Create the request
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        // Schedule the request with the system
        scheduleNotification(request: request)
    }

    func returnNotificationTrigger(item: Task) -> UNCalendarNotificationTrigger {
        // debugPrint(#function + "Called by \(function)")
        let triggerDateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second, .calendar], from: firstTriggerDate(forItem: item))

        return UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: item.repeats)
    }

    func removeNotifications(withIdentifiers identifiers: [String], function: String = #function) {
        debugPrint(#function + "Called by \(function)")
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeOrphanedNotifications(function: String = #function) {
        debugPrint(#function + "Called by \(function)")
//        let realm = try! Realm()
        let items = TaskCategory.returnTaskCategory(CategorySelections.All.rawValue).taskList.filter("isDeleted = %@", false)
        let itemIDArray: [String] = items.map { $0.uuidString }

        center.getPendingNotificationRequests { pendingRequests in
            // This has to happen inside the closure, otherwise the values to notificationIDArray never get written in time.
            // Seems to execute async
            var notificationIDArray: [String] = []
            notificationIDArray = pendingRequests.map { $0.identifier }
            let itemSet = Set(itemIDArray)
            print("itemSet count: \(itemSet.count)")
            let notificationSet = Set(notificationIDArray)
            print("notificationSet count: \(notificationSet.count)")
            let orphans = notificationSet.subtracting(itemSet)
            print("orphans count: \(orphans.count)")

            guard orphans.count > 0 else { return }
            self.removeNotifications(withIdentifiers: Array(orphans))
        }
    }

    func checkForMissingNotifications(function: String = #function) {
        debugPrint(#function + "Called by \(function)")
        center.getPendingNotificationRequests { pendingRequests in
            let realm = try! Realm()
            let items = TaskCategory.returnTaskCategory(CategorySelections.All.rawValue).taskList.filter("isDeleted = %@", false)
            debugPrint("Pending Requests Count: \(pendingRequests.count)")
            let pendingRequestsSet = Set(pendingRequests.map { $0.identifier })
            debugPrint("Pending Requests Set Count: \(pendingRequestsSet.count)")
            let itemIDArray: [String] = items.map { $0.uuidString }
            debugPrint("Item Array Count: \(itemIDArray.count)")
            itemIDArray.forEach { itemID in
                if !pendingRequestsSet.contains(itemID) {
                    if let item = realm.object(ofType: Task.self, forPrimaryKey: itemID) {
                        self.createNewNotification(forItem: item)
                    }
                }
            }
        }
    }

    func batchModifyNotifications(items: [Task?], function: String = #function) {
        debugPrint(#function + "Called by \(function)")
        DispatchQueue.main.async {
            items.forEach { item in
                if let item = item {
                    if !item.isDeleted {
                        debugPrint("Updating Notification")
                        self.createNewNotification(forItem: item)
                    } else {
                        debugPrint("Removing notification for soft deleted item")
                        self.removeNotifications(withIdentifiers: [item.uuidString])
                    }
                }
            }
        }
    }

    func checkNotificationPermission() {
        // Request permission to display alerts and play sounds
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { _, _ in
            // Enable or disable features based on authorization.
        }
    }

//    func refreshAllNotifications(function: String = #function) {
//        debugPrint(#function + "Called by \(function)")
//        //Do some cleanup first
//        removeOrphanedNotifications()
//
//        center.getPendingNotificationRequests { (pendingRequests) in
//            let realm = try! Realm()
//            let items = realm.objects(Task.self).filter("isDeleted = %@", false).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
//            debugPrint("Starting count for items list is \(items.count)")
//            // 1. Iterate through all pending requests and check that the trigger matches what *would* be set with the item's current properties
//            // 2. If there's a match, the notification does not need to be updated and the item can be ignored. Add to Set of ignored items
//            // 3. After iteration has finished, subtract set from set of all qualifying Task in Realm and save as new set of items
//            // 4. Add new notifications for the set of items
//            var itemsToIgnore = Set<Task>()
//            // 1.
//            pendingRequests.forEach({ (request) in
//                if let item = realm.object(ofType: Task.self, forPrimaryKey: request.identifier) {
//                    debugPrint("Found item matching notification request ID: \(item.title!)")
//                    // 2.
//                    let trigger = request.trigger as! UNCalendarNotificationTrigger
//                    //Calendar will never match. So set them equal, then compare
//                    var requestDateComponents = trigger.dateComponents
//                    var itemDateComponents = self.returnNotificationTrigger(item: item).dateComponents
//                    requestDateComponents.calendar = Calendar.autoupdatingCurrent
//                    itemDateComponents.calendar = Calendar.autoupdatingCurrent
//
//                    if requestDateComponents == itemDateComponents {
//                        debugPrint("Item notification does not need updating. Added to ignore list: \(item.title!)")
//                        itemsToIgnore.insert(item)
//                    }
//                } else {
//                    debugPrint("Did not find matching item for request ID. Removing notification")
//                    self.removeNotifications(withIdentifiers: [request.identifier])
//                }
//            })
//            // 3.
//            debugPrint("Ignored items count is: \(itemsToIgnore.count)")
//            let itemsNeedingNotificationRefresh = Set(items).subtracting(itemsToIgnore)
//            debugPrint("itemsNeedingNotificationRefresh count is: \(itemsNeedingNotificationRefresh.count)")
//            // 4.
//            itemsNeedingNotificationRefresh.forEach({ (item) in
//                self.createNewNotification(forItem: item)
//            })
//        }
//    }

    func refreshAllNotifications(function: String = #function) {
        debugPrint(#function + "Called by \(function)")
//        let realm = try! Realm()
        let items = TaskCategory.returnTaskCategory(CategorySelections.All.rawValue).taskList.filter("isDeleted = %@", false)//.sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
        batchModifyNotifications(items: items.map { $0 })
    }

    private func scheduleNotification(request: UNNotificationRequest, function: String = #function) {
        debugPrint(#function + "Called by \(function)")
        center.add(request) { error in
            if error != nil {
                debugPrint("Failed to create notification with error: \(String(describing: error))")
            } else {
                debugPrint("Notification created successfully")
            }
        }
    }
}
