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

    func firstTriggerDate(forItem item: Items) -> Date {
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
        if let item = realm.object(ofType: Items.self, forPrimaryKey: id) {
            let itemSegment = item.segment
            // Only count the items who's segment is equal or greater than the current item
            // TODO: Maybe should match this against "originalSegment"?
            let items = realm.objects(Items.self).filter("segment >= %@ AND isDeleted = %@ AND completeUntil <= %@", itemSegment, false, item.completeUntil).sorted(byKeyPath: "dateModified").sorted(byKeyPath: "segment")
            if let currentItemIndex = items.index(of: item) {
                printDebug("Item title: \(item.title!) at index: \(currentItemIndex)")
                badgeCount = currentItemIndex + 1
                printDebug("setBadgeNumber to \(badgeCount) for \(item.title!)")
            }
        }

        return badgeCount
    }

    func createNewNotification(forItem item: Items) {
        checkNotificationPermission()

        let title = item.title!
        let notes = item.notes
        let segment = item.segment
        let id = item.uuidString
        //let triggerDate = firstTriggerDate(forItem: item)
        //let repeats = item.repeats

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

        //let triggerDateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second, .calendar], from: triggerDate)

        let trigger = returnNotificationTrigger(item: item)

        // Create the request
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        // Schedule the request with the system
        scheduleNotification(request: request)
    }
    
    func returnNotificationTrigger(item: Items) -> UNCalendarNotificationTrigger {
        let triggerDateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second, .calendar], from: firstTriggerDate(forItem: item))
        
        return UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: item.repeats)
    }

    func removeNotifications(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeOrphanedNotifications() {
        let realm = try! Realm()
        let items = realm.objects(Items.self).filter("isDeleted = %@", false)
        let itemIDArray: [String] = items.map { $0.uuidString }

        center.getPendingNotificationRequests { pendingRequests in
            //This has to happen inside the closure, otherwise the values to notificationIDArray never get written in time.
            //Seems to execute async
            var notificationIDArray: [String] = []
            notificationIDArray = pendingRequests.map { $0.identifier }
            let itemSet = Set(itemIDArray)
            print("itemSet count: \(itemSet.count)")
            let notificationSet = Set(notificationIDArray)
            print("notificationSet count: \(notificationSet.count)")
            let orphans = notificationSet.subtracting(itemSet)
            print("orphans count: \(orphans.count)")
            self.removeNotifications(withIdentifiers: Array(orphans))
        }
    }

    func checkNotificationPermission() {
        // Request permission to display alerts and play sounds
        /* center.requestAuthorization(options: [.alert, .sound, .badge, .provisional, .providesAppNotificationSettings]) { (status, error) in
            //
         } */
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
    
    func refreshAllNotifications() {
        //Do some cleanup first
        removeOrphanedNotifications()
        
        let realm = try! Realm()
        let items = realm.objects(Items.self).filter("isDeleted = %@", false).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
        
        center.getPendingNotificationRequests { (pendingRequests) in
            // 1. Iterate through all pending requests and check that the trigger matches what *would* be set with the item's current properties
            // 2. If there's a match, the notification does not need to be updated and the item can be ignored. Add to Set of ignored items
            // 3. After iteration has finished, subtract set from set of all qualifying Items in Realm and save as new set of items
            // 4. Add new notifications for the set of items
            var itemsToIgnore = Set<Items>()
            // 1.
            pendingRequests.forEach({ (request) in
                if let item = realm.object(ofType: Items.self, forPrimaryKey: request.identifier) {
                    // 2.
                    if request.trigger == self.returnNotificationTrigger(item: item) {
                        itemsToIgnore.insert(item)
                    }
                } else {
                    self.removeNotifications(withIdentifiers: [request.identifier])
                }
            })
            // 3.
            let itemsNeedingNotificationRefresh = Set(items).subtracting(itemsToIgnore)
            
            // 4.
            itemsNeedingNotificationRefresh.forEach({ (item) in
                self.createNewNotification(forItem: item)
            })
        }
    }

    private func scheduleNotification(request: UNNotificationRequest) {
        center.add(request) { error in
            if error != nil {
                printDebug("Failed to create notification with error: \(String(describing: error))")
            } else {
                printDebug("Notification created successfully")
            }
        }
    }
}
