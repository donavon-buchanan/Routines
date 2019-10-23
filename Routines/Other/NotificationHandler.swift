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

    func firstTriggerDate(forTask task: Task) -> Date {
        var segmentTime = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: Date())

        segmentTime.hour = Options.getOptionHour(segment: task.segment)
        segmentTime.minute = Options.getOptionMinute(segment: task.segment)
        segmentTime.second = 0

        // check if task hasn't been marked as complete already
        if task.completeUntil < Date().endOfDay, Date() <= segmentTime.date! {
            debugPrint("1: Task completeUntil is before end of today. Now is before or equal to the segment trigger date")
            return segmentTime.date!
        } else if task.completeUntil > Date().endOfDay, Date() <= segmentTime.date! {
            debugPrint("2: Task completeUntil is after end of today. Now is before or equal to the segment trigger date.")
            return segmentTime.date!.nextDay
        } else {
            debugPrint("3: Returning nextDay segment trigger date.")
            return segmentTime.date!.nextDay
        }

        // return segmentTime.date!
    }

    func setBadgeNumber(forTask task: Task) -> Int {
        //First get the category so we can find the index of the task in its list
        let taskCategory = TaskCategory.returnTaskCategory(task.segment)
        //Find the index. This will act as the base for our badge number since the list is ordered
        if let index = taskCategory.taskList.index(of: task) {
            //If the index is found, return index position + 1
            return index + 1
        } else {
            //If it's not found, something went wrong and we should just 0 out the badge
            return 0
        }
    }

    func createNewNotification(forTask task: Task, function: String = #function) {
        guard Options.getSegmentNotification(segment: task.segment) else {
            removeNotifications(withIdentifiers: [task.uuidString])
            return
        }
        debugPrint(#function + "Called by \(function)")
        checkNotificationPermission()

        let title = task.title!
        let notes = task.notes
        let segment = task.segment
        let id = task.uuidString
        // let triggerDate = firstTriggerDate(forTask: task)
        // let repeats = task.repeats

        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.threadIdentifier = String(segment)

        content.badge = setBadgeNumber(forTask: task) as NSNumber

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

        let trigger = returnNotificationTrigger(task: task)

        // Create the request
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        // Schedule the request with the system
        scheduleNotification(request: request)
    }

    func returnNotificationTrigger(task: Task) -> UNCalendarNotificationTrigger {
        // debugPrint(#function + "Called by \(function)")
        // The day component here is causing problems
//        let triggerDateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute, .second, .calendar], from: firstTriggerDate(forTask: task))
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second, .calendar], from: firstTriggerDate(forTask: task))
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: task.repeats)

        return trigger
    }

    func removeNotifications(withIdentifiers identifiers: [String], function: String = #function) {
        debugPrint(#function + "Called by \(function)")
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeOrphanedNotifications(function: String = #function) {
        debugPrint(#function + "Called by \(function)")
//        let realm = try! Realm()
        let tasks = TaskCategory.returnTaskCategory(CategorySelections.allDay.rawValue).taskList
        let taskIDArray: [String] = tasks.map { $0.uuidString }

        center.getPendingNotificationRequests { pendingRequests in
            // This has to happen inside the closure, otherwise the values to notificationIDArray never get written in time.
            // Seems to execute async
            var notificationIDArray: [String] = []
            notificationIDArray = pendingRequests.map { $0.identifier }
            let taskSet = Set(taskIDArray)
            print("taskSet count: \(taskSet.count)")
            let notificationSet = Set(notificationIDArray)
            print("notificationSet count: \(notificationSet.count)")
            let orphans = notificationSet.subtracting(taskSet)
            print("orphans count: \(orphans.count)")

            guard !orphans.isEmpty else { return }
            self.removeNotifications(withIdentifiers: Array(orphans))
        }
    }

    func checkForMissingNotifications(function: String = #function) {
        debugPrint(#function + "Called by \(function)")
        center.getPendingNotificationRequests { pendingRequests in
            let realm = try? Realm()
            let tasks = TaskCategory.returnTaskCategory(CategorySelections.allDay.rawValue).taskList
            debugPrint("Pending Requests Count: \(pendingRequests.count)")
            let pendingRequestsSet = Set(pendingRequests.map { $0.identifier })
            debugPrint("Pending Requests Set Count: \(pendingRequestsSet.count)")
            let taskIDArray: [String] = tasks.map { $0.uuidString }
            debugPrint("Task Array Count: \(taskIDArray.count)")
            taskIDArray.forEach { taskID in
                if !pendingRequestsSet.contains(taskID) {
                    if let task = realm?.object(ofType: Task.self, forPrimaryKey: taskID) {
                        self.createNewNotification(forTask: task)
                    }
                }
            }
        }
    }

    func batchModifyNotifications(tasks: [Task?], function: String = #function) {
        debugPrint(#function + "Called by \(function)")
        DispatchQueue.main.async {
            tasks.forEach { task in
                if let task = task {
                    if Options.getSegmentNotification(segment: task.segment) {
                        self.createNewNotification(forTask: task)
                    } else {
                        debugPrint("Removing notification for soft deleted task")
                        self.removeNotifications(withIdentifiers: [task.uuidString])
                    }
                }
            }
        }
    }

    func checkNotificationPermission() {
        // Request permission to display alerts and play sounds
        #if !targetEnvironment(simulator)
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { _, _ in
            // Enable or disable features based on authorization.
        }
        #endif
    }

//    func refreshAllNotifications(function: String = #function) {
//        debugPrint(#function + "Called by \(function)")
//        //Do some cleanup first
//        removeOrphanedNotifications()
//
//        center.getPendingNotificationRequests { (pendingRequests) in
//            let realm = try! Realm()
//            let tasks = realm.objects(Task.self).filter("isDeleted = %@", false).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
//            debugPrint("Starting count for tasks list is \(tasks.count)")
//            // 1. Iterate through all pending requests and check that the trigger matches what *would* be set with the task's current properties
//            // 2. If there's a match, the notification does not need to be updated and the task can be ignored. Add to Set of ignored tasks
//            // 3. After iteration has finished, subtract set from set of all qualifying Task in Realm and save as new set of tasks
//            // 4. Add new notifications for the set of tasks
//            var tasksToIgnore = Set<Task>()
//            // 1.
//            pendingRequests.forEach({ (request) in
//                if let task = realm.object(ofType: Task.self, forPrimaryKey: request.identifier) {
//                    debugPrint("Found task matching notification request ID: \(task.title!)")
//                    // 2.
//                    let trigger = request.trigger as! UNCalendarNotificationTrigger
//                    //Calendar will never match. So set them equal, then compare
//                    var requestDateComponents = trigger.dateComponents
//                    var taskDateComponents = self.returnNotificationTrigger(task: task).dateComponents
//                    requestDateComponents.calendar = Calendar.autoupdatingCurrent
//                    taskDateComponents.calendar = Calendar.autoupdatingCurrent
//
//                    if requestDateComponents == taskDateComponents {
//                        debugPrint("Task notification does not need updating. Added to ignore list: \(task.title!)")
//                        tasksToIgnore.insert(task)
//                    }
//                } else {
//                    debugPrint("Did not find matching task for request ID. Removing notification")
//                    self.removeNotifications(withIdentifiers: [request.identifier])
//                }
//            })
//            // 3.
//            debugPrint("Ignored tasks count is: \(tasksToIgnore.count)")
//            let tasksNeedingNotificationRefresh = Set(tasks).subtracting(tasksToIgnore)
//            debugPrint("tasksNeedingNotificationRefresh count is: \(tasksNeedingNotificationRefresh.count)")
//            // 4.
//            tasksNeedingNotificationRefresh.forEach({ (task) in
//                self.createNewNotification(forTask: task)
//            })
//        }
//    }

    func refreshAllNotifications(function: String = #function) {
        debugPrint(#function + "Called by \(function)")
//        let realm = try! Realm()
        let tasks = TaskCategory.returnTaskCategory(CategorySelections.allDay.rawValue).taskList // .sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
        batchModifyNotifications(tasks: tasks.map { $0 })
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

// class UNNotificationTriggerWIthFirstTriggerDate: UNCalendarNotificationTrigger {
//
////    private var nextTriggerDate: Date
////    private override var dateComponents: DateComponents
////    private override var repeats: Bool
//    private var task: Task?
//
//    public convenience init(task: Task, dateComponents: DateComponents, repeats: Bool) {
//        self.init(dateMatching: dateComponents, repeats: repeats)
//        self.task = task
//    }
//
//    override open func nextTriggerDate() -> Date? {
//        if let task = task {
//            if Date() > task.completeUntil {
//                debugPrint("Setting nextTriggerDate to default")
//                return super.nextTriggerDate()
//            } else {
//                debugPrint("Setting nextTriggerDate to nextDay")
//                return super.nextTriggerDate()?.nextDay
//            }
//        } else {
//            debugPrint("Returning default next trigger date")
//            return super.nextTriggerDate()
//        }
//    }
// }
