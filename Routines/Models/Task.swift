//
//  Task.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Task: Object {
    lazy var notificationHanlder = NotificationHandler()

    static let realmDispatchQueueLabel: String = "background"

    override static func ignoredProperties() -> [String] {
        ["notificationHanlder"]
    }

    dynamic var title: String?
    dynamic var dateModified = Date()
    dynamic var segment: Int = 0
    dynamic var originalSegment: Int = 0
    dynamic var completeUntil = Date()
    dynamic var repeats: Bool = true
    dynamic var notes: String?
    dynamic var priority: Int = 0
    let category = LinkingObjects(fromType: TaskCategory.self, property: "taskList")

    // For syncing
    dynamic var isDeleted: Bool = false

    required convenience init(title: String, segment: Int, repeats: Bool, notes: String?) {
        debugPrint("Running init on Task")
        self.init()
        self.title = title
        self.segment = segment
        originalSegment = segment
        self.repeats = repeats
        self.notes = notes

        if Date() >= notificationHanlder.firstTriggerDate(forItem: self), RoutinesPlus.getShowUpcomingTasks() {
            completeUntil = Date().startOfNextDay
        }
    }

    // Notification identifier
    dynamic var uuidString: String = UUID().uuidString
    override static func primaryKey() -> String? {
        "uuidString"
    }

    func addNewItem() {
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        //realm.add(self)
                        TaskCategory.returnTaskCategory(self.segment).taskList.append(self)
                        
                        //This line adds all tasks to the "All" category object
                        TaskCategory.returnTaskCategory(CategorySelections.All.rawValue).taskList.append(self)
                    }
                } catch {
                    realm.cancelWrite()
                }
            }
        }
        notificationHanlder.createNewNotification(forItem: self)
    }
    
    //MUST be called from within a realm write operation
    private func removeTaskFromCategoryList(segment: Int) {
        let previousCategoryList = TaskCategory.returnTaskCategory(segment).taskList
        if let index = previousCategoryList.index(of: self) {
            previousCategoryList.remove(at: index)
        }
    }
    
    //MUST be called from within a realm write operation
    //This is probably overkill and potentially problematic doing a -1 count on an index that might already be 0
    private func moveTaskInList(task: Task, categories: [Int]?, toIndex: Int?) {
        let taskPrimaryCategory = TaskCategory.returnTaskCategory(task.segment)
        let taskPrimaryCategoryIndex = taskPrimaryCategory.taskList.index(of: task)
        let lastPrimaryCategoryIndex = taskPrimaryCategory.taskList.count - 1
        let allCategory = TaskCategory.returnTaskCategory(CategorySelections.All.rawValue)
        let lastAllCategoryIndex = allCategory.taskList.count - 1
        let taskAllCategoryIndex = allCategory.taskList.index(of: task)
        // If specific categories were provided, act on those
        // Else, default to the task's primary (segment) category
        // toIndex should default to the last index of the list if not provided
        if let categories = categories {
            categories.forEach { (category) in
                let taskCategory = TaskCategory.returnTaskCategory(category)
                let lastIndex = taskCategory.taskList.count - 1
                if let taskCategoryIndex = taskCategory.taskList.index(of: task) {
                    taskCategory.taskList.move(from: taskCategoryIndex, to: toIndex ?? lastIndex)
                }
            }
        } else {
            if let currentIndex = taskPrimaryCategoryIndex {
                taskPrimaryCategory.taskList.move(from: currentIndex, to: toIndex ?? lastPrimaryCategoryIndex)
            }
            if let allIndex = taskAllCategoryIndex {
                allCategory.taskList.move(from: allIndex, to: lastAllCategoryIndex)
            }
        }
    }

    func updateItem(title: String, segment: Int, repeats: Bool, notes: String?) {
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let previousSegment = self.segment
                do {
                    try realm.write {
                        self.dateModified = Date()
                        self.title = title
                        self.segment = segment
                        self.originalSegment = segment
                        self.repeats = repeats
                        self.notes = notes
                        //Maintain position in list if segment has not changed
                        if previousSegment != segment {
                            removeTaskFromCategoryList(segment: previousSegment)
                            TaskCategory.returnTaskCategory(segment).taskList.append(self)
                        }
                    }
                } catch {
                    realm.cancelWrite()
                }
            }
        }
        notificationHanlder.createNewNotification(forItem: self)
    }

    func completeItem() {
        if !repeats {
            softDelete()
            notificationHanlder.removeNotifications(withIdentifiers: [self.uuidString])
        } else {
            debugPrint("marking completed until: \(Date().startOfNextDay)")
//            DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
//                autoreleasepool {
//                    let realm = try! Realm()
//                    do {
//                        try realm.write {
//                            self.segment = self.originalSegment
//                            self.completeUntil = Date().startOfNextDay
//                            self.dateModified = Date()
//                            //Move task to bottom of list
//                            self.moveTaskInList(task: self, categories: nil, toIndex: nil)
//                        }
//                    } catch {
//                        // print("failed to save completeUntil")
//                        fatalError("Error completing item: \(error)")
//                    }
//                }
//            }
            let realm = try! Realm()
            do {
                try realm.write {
                    self.segment = self.originalSegment
                    self.completeUntil = Date().startOfNextDay
                    self.dateModified = Date()
                    //Move task to bottom of list
                    self.moveTaskInList(task: self, categories: nil, toIndex: nil)
                }
            } catch {
                // print("failed to save completeUntil")
                realm.cancelWrite()
            }
            notificationHanlder.createNewNotification(forItem: self)
        }
    }

    static func batchComplete(itemArray: [Task]) {
        debugPrint(#function)
        var itemsToComplete: [Task] = []
        var itemsToSoftDelete: [Task] = []

        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
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
                    //Separate into two write transactions so the index is updated before trying to move tasks
                    realm.beginWrite()
                    itemsToSoftDelete.forEach { item in
//                        item.isDeleted = true
                        item.removeTaskFromCategoryList(segment: item.segment)
                        item.removeTaskFromCategoryList(segment: CategorySelections.All.rawValue)
                        realm.delete(item)
                    }
                    try realm.commitWrite()
                    realm.beginWrite()
                    itemsToComplete.forEach { item in
                        item.segment = item.originalSegment
                        item.completeUntil = Date().startOfNextDay
                        item.dateModified = Date()
                        //Move item to bottom
                        item.moveTaskInList(task: item, categories: nil, toIndex: nil)
                    }
                    try realm.commitWrite()
                } catch {
                    realm.cancelWrite()
                }
            }
        }

        let notificationHandler = NotificationHandler()

        itemsToComplete.forEach { item in
            notificationHandler.createNewNotification(forItem: item)
        }

        notificationHandler.removeNotifications(withIdentifiers: (itemsToSoftDelete.map { $0.uuidString }))
    }

    // MARK: - iCloud Sync

    // Sync soft delete
    func softDelete() {
        debugPrint("soft deleting item")
        notificationHanlder.removeNotifications(withIdentifiers: [self.uuidString])
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
//                        self.isDeleted = true // Need to actually remove them since we're not using IceCream for sync
                        removeTaskFromCategoryList(segment: self.segment)
                        removeTaskFromCategoryList(segment: CategorySelections.All.rawValue)
                        realm.delete(self)
                    }
                } catch {
                    realm.cancelWrite()
                }
            }
        }
        // AppDelegate.refreshNotifications()
    }

    static func batchSoftDelete(itemArray: [Task]) {
        debugPrint(#function)
        let notificationHandler = NotificationHandler()

        notificationHandler.removeNotifications(withIdentifiers: (itemArray.map { $0.uuidString }))

        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    realm.beginWrite()
                    itemArray.forEach { item in
//                        item.isDeleted = true  // Need to actually remove them since we're not using IceCream for sync
                        item.removeTaskFromCategoryList(segment: item.segment)
                        item.removeTaskFromCategoryList(segment: CategorySelections.All.rawValue)
                        realm.delete(item)
                    }
                    try realm.commitWrite()
                } catch {
                    realm.cancelWrite()
                }
            }
        }
        // AppDelegate.refreshNotifications()
    }

    // MARK: - Notification Handling

//    static func setBadgeNumber(id: String) -> Int {
//        var badgeCount = 0
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                // Get all the items in or under the current segment.
//                if let item = realm.object(ofType: Task.self, forPrimaryKey: id) {
//                    let itemSegment = item.segment
//                    // Only count the items who's segment is equal or greater than the current item
//                    // TODO: Maybe should match this against "originalSegment"?
//                    let items = realm.objects(Task.self).filter("segment >= %@ AND isDeleted = %@ AND completeUntil <= %@", itemSegment, false, item.completeUntil).sorted(byKeyPath: "dateModified").sorted(byKeyPath: "segment")
//                    guard let currentItemIndex = items.index(of: item) else { return }
//                    debugPrint("Item title: \(item.title!) at index: \(currentItemIndex)")
//                    badgeCount = currentItemIndex + 1
//                    debugPrint("setBadgeNumber to \(badgeCount) for \(item.title!)")
//                }
//            }
//        }
//
//        return badgeCount
//    }

//    static func requestNotificationPermission() {
//        let center = UNUserNotificationCenter.current()
//        // let center = UNUserNotificationCenter.current()
//        // Request permission to display alerts and play sounds
//        if #available(iOS 12.0, *) {
//            center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { _, _ in
//                // Enable or disable features based on authorization.
//            }
//        } else {
//            // Fallback on earlier versions
//            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
//                // Enable or disable features based on authorization.
//            }
//        }
//    }

    // Remove notifications for Item
//    func removeNotification(uuidStrings: [String]) {
//        let center = UNUserNotificationCenter.current()
//        center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
//    }

//    func removeNotification() {
//        debugPrint("Removing notification for id: \(uuidString)")
//        let uuidStrings: [String] = ["\(uuidString)0", "\(uuidString)1", "\(uuidString)2", "\(uuidString)3"]
//
//        let center = UNUserNotificationCenter.current()
//        // Running removal of base string separately just to be double sure
//        center.removePendingNotificationRequests(withIdentifiers: [uuidString])
//        center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
//    }
    
    //MUST be called from within a realm write operation
    private func moveTaskCategory(from: Int, to: Int) {
        removeTaskFromCategoryList(segment: from)
        TaskCategory.returnTaskCategory(to).taskList.append(self)
    }

    func snooze() {
//        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                do {
//                    try realm.write {
//                        self.dateModified = Date()
//                        moveTaskCategory(from: segment, to: snoozeTo())
//                        self.segment = snoozeTo()
//                    }
//                } catch {
//                    debugPrint("failed to snooze item")
//                }
//            }
//
//            
//        }
        let realm = try! Realm()
        do {
            try realm.write {
                self.dateModified = Date()
                moveTaskCategory(from: segment, to: snoozeTo())
                self.segment = snoozeTo()
            }
        } catch {
            realm.cancelWrite()
        }
        notificationHanlder.createNewNotification(forItem: self)
        debugPrint("Snoozing to \(segment). Original segment was \(originalSegment)")
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
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        switch self.segment {
                        case 3:
                            moveTaskCategory(from: segment, to: 0)
                            self.segment = 0
                        default:
                            moveTaskCategory(from: segment, to: (self.segment + 1))
                            self.segment += 1
                        }
                    }
                } catch {
                    realm.cancelWrite()
                }
            }
        }
    }

//    func addNewNotification() {
//        let firstDate = firstTriggerDate(segment: segment)
//
//        // Check if notifications are enabled for the segment first
//        // Also check if item hasn't been marked as complete already
//        if Options.getSegmentNotification(segment: segment), completeUntil < Date().endOfDay, Date() <= firstTriggerDate(segment: segment) {
//            createNotification(title: title!, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//            debugPrint("Notification Date: \(firstDate)")
//        } else if Options.getSegmentNotification(segment: segment), completeUntil > Date().endOfDay, Date() <= firstTriggerDate(segment: segment) {
//            createNotification(title: title!, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//            debugPrint("Notification Date: \(firstDate)")
//        } else {
//            createNotification(title: title!, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate.nextDay)
//            debugPrint("Notification Date: Next Day - \(firstDate.nextDay)")
//        }
//    }

//    func createNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate _: Date) {
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.sound = UNNotificationSound.default
//        content.threadIdentifier = String(getItemSegment(id: uuidString))
//
//        content.badge = NSNumber(integerLiteral: Task.setBadgeNumber(id: uuidString))
//
//        if let notesText = notes {
//            content.body = notesText
//        }
//
//        // Assign the category (and the associated actions).
//        switch segment {
//        case 1:
//            content.categoryIdentifier = "afternoon"
//        case 2:
//            content.categoryIdentifier = "evening"
//        case 3:
//            content.categoryIdentifier = "night"
//        default:
//            content.categoryIdentifier = "morning"
//        }
//
//        var dateComponents = DateComponents()
//        dateComponents.calendar = Calendar.autoupdatingCurrent
//        // dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: firstDate)
//        dateComponents.timeZone = TimeZone.autoupdatingCurrent
//
//        dateComponents.hour = Options.getOptionHour(segment: segment)
//        dateComponents.minute = Options.getOptionMinute(segment: segment)
//
//        #if DEBUG
//            if repeats {
//                debugPrint("Task titled \(title) repeats")
//            } else {
//                debugPrint("Task titled \(title) does NOT repeat")
//            }
//        #endif
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
//
//        // Create the request
//        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
//
//        // Schedule the request with the system
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.add(request) { error in
//            if error != nil {
//                debugPrint("Failed to create notification with error: \(String(describing: error))")
//            } else {
//                debugPrint("Notification created successfully")
//            }
//        }
//    }

//    func getItemSegment(id: String) -> Int {
//        var identifier: String {
//            if id.count > 36 {
//                return String(id.dropLast())
//            } else {
//                return id
//            }
//        }
//        var segment = Int()
//        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let item = realm.object(ofType: Task.self, forPrimaryKey: identifier) {
//                    segment = item.segment
//                }
//            }
//        }
//        return segment
//    }

    func setDailyRepeat(_ bool: Bool) {
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        self.repeats = bool
                    }
                } catch {
                    realm.cancelWrite()
                }
            }
        }
    }

//    func firstTriggerDate(segment: Int) -> Date {
//        var segmentTime = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: Date())
//        segmentTime.hour = Options.getOptionHour(segment: segment)
//        segmentTime.minute = Options.getOptionMinute(segment: segment)
//        segmentTime.second = 0
//
//        // The actual day is handled in addNewNotification()
//        // The name of this func is now a bit misleading
//        debugPrint("\(#function) - \(segmentTime.date!)")
//        return segmentTime.date!
//    }

    static func getCountForSegment(segment: Int) -> Int {
        var count = Int()
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Task.self).filter("segment = \(segment)").count
            }
        }
        return count
    }

    static func getItemCount() -> Int {
        var count = Int()
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Task.self).count
            }
        }
        return count
    }
}

//extension Task: CKRecordConvertible {
//    // Yep, leave it blank!
//}
//
//extension Task: CKRecordRecoverable {
//    // Leave it blank, too.
//}
