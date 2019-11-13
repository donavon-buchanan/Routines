//
//  Task.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    lazy var notificationHanlder = NotificationHandler()

    static let realmDispatchQueueLabel: String = "background"

    override static func ignoredProperties() -> [String] {
        ["notificationHanlder"]
    }

    @objc dynamic var title: String?
    @objc dynamic var dateModified = Date()
    @objc dynamic var segment: Int = 0
    @objc dynamic var originalSegment: Int = 0
    @objc dynamic var completeUntil = Date()
    @objc dynamic var repeats: Bool = true
    @objc dynamic var notes: String?
    @objc dynamic var priority: Int = 0
//    let category = LinkingObjects(fromType: TaskCategory.self, property: "taskList")

    // For syncing
    @objc dynamic var isDeleted: Bool = false

    required convenience init(title: String, segment: Int, repeats: Bool, notes: String?) {
        debugPrint("Running init on Task")
        self.init()
        self.title = title
        self.segment = segment
        originalSegment = segment
        self.repeats = repeats
        self.notes = notes

        if Date() >= notificationHanlder.firstTriggerDate(forTask: self), RoutinesPlus.getShowUpcomingTasks() {
            completeUntil = Date().startOfNextDay
        }
    }

    // Notification identifier
    @objc dynamic var uuidString: String = UUID().uuidString
    override static func primaryKey() -> String? {
        "uuidString"
    }

    func addNewTask() {
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                if let realm = try? Realm() {
                    do {
                        try realm.write {
                            // realm.add(self)
                            TaskCategory.returnTaskCategory(self.segment).taskList.append(self)

                            // This line adds all tasks to the "All" category object
                            TaskCategory.returnTaskCategory(CategorySelections.allDay.rawValue).taskList.append(self)
                        }
                    } catch {
                        realm.cancelWrite()
                    }
                }
            }
        }
        notificationHanlder.createNewNotification(forTask: self)
    }

    // MUST be called from within a realm write operation
    private func removeTaskFromCategoryList(segment: Int) {
        let previousCategoryList = TaskCategory.returnTaskCategory(segment).taskList
        if let index = previousCategoryList.index(of: self) {
            previousCategoryList.remove(at: index)
        }
    }

    // MUST be called from within a realm write operation
    // This is probably overkill and potentially problematic doing a -1 count on an index that might already be 0
    private func moveTaskInList(task: Task, categories: [Int]?, toIndex: Int?) {
        let taskPrimaryCategory = TaskCategory.returnTaskCategory(task.segment)
        let taskPrimaryCategoryIndex = taskPrimaryCategory.taskList.index(of: task)
        let lastPrimaryCategoryIndex = taskPrimaryCategory.taskList.count - 1
        let allCategory = TaskCategory.returnTaskCategory(CategorySelections.allDay.rawValue)
        let lastAllCategoryIndex = allCategory.taskList.count - 1
        let taskAllCategoryIndex = allCategory.taskList.index(of: task)
        // If specific categories were provided, act on those
        // Else, default to the task's primary (segment) category
        // toIndex should default to the last index of the list if not provided
        if let categories = categories {
            categories.forEach { category in
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

    func updateTask(title: String, segment: Int, repeats: Bool, notes: String?) {
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                if let realm = try? Realm() {
                    let previousSegment = self.segment
                    do {
                        try realm.write {
                            self.dateModified = Date()
                            self.title = title
                            self.segment = segment
                            self.originalSegment = segment
                            self.repeats = repeats
                            self.notes = notes
                            // Maintain position in list if segment has not changed
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
        }
        notificationHanlder.createNewNotification(forTask: self)
    }

    func completeTask() {
        if !repeats {
            deleteTask()
//            notificationHanlder.removeNotifications(withIdentifiers: [self.uuidString])
        } else {
            debugPrint("marking completed until: \(Date().startOfNextDay)")
            if let realm = try? Realm() {
                do {
                    try realm.write {
                        // Move task to bottom of original list
                        if self.segment == self.originalSegment {
                            self.moveTaskInList(task: self, categories: nil, toIndex: nil)
                        } else {
                            self.moveTaskCategory(fromSegment: self.segment, toSegment: self.originalSegment)
                        }
                        self.segment = self.originalSegment
                        self.completeUntil = Date().startOfNextDay
                        self.dateModified = Date()
                    }
                } catch {
                    // print("failed to save completeUntil")
                    realm.cancelWrite()
                }
                notificationHanlder.createNewNotification(forTask: self)
            }
        }
    }

    static func batchComplete(taskArray: [Task]) {
        debugPrint(#function)
        var tasksToComplete: [Task] = []
        var tasksToDelete: [Task] = []

        taskArray.forEach { task in
            if task.repeats {
                tasksToComplete.append(task)
            } else {
                tasksToDelete.append(task)
            }
        }

        let notificationHandler = NotificationHandler()

        // Remove these before deleting. They won't exist for reference later
        notificationHandler.removeNotifications(withIdentifiers: (tasksToDelete.map { $0.uuidString }))

        batchDelete(taskArray: tasksToDelete)

        if let realm = try? Realm() {
            do {
                try realm.write {
                    tasksToComplete.forEach { task in
                        // Move task to bottom of original list
                        if task.segment == task.originalSegment {
                            task.moveTaskInList(task: task, categories: nil, toIndex: nil)
                        } else {
                            task.moveTaskCategory(fromSegment: task.segment, toSegment: task.originalSegment)
                        }
                        task.segment = task.originalSegment
                        task.completeUntil = Date().startOfNextDay
                        task.dateModified = Date()
                    }
                }
            } catch {
                realm.cancelWrite()
            }
        }

        // Now that completed tasks properties have been updated, udpate the notifications
        tasksToComplete.forEach { task in
            notificationHandler.createNewNotification(forTask: task)
        }
    }

    // MARK: - iCloud Sync

    // Sync soft delete
    func deleteTask() {
        debugPrint("soft deleting task")
        notificationHanlder.removeNotifications(withIdentifiers: [self.uuidString])
        if let realm = try? Realm() {
            do {
                realm.beginWrite()
                removeTaskFromCategoryList(segment: segment)
                removeTaskFromCategoryList(segment: CategorySelections.allDay.rawValue)
                realm.delete(self)
                try realm.commitWrite()
            } catch {
                realm.cancelWrite()
            }
        }
        // AppDelegate.refreshNotifications()
    }

    static func batchDelete(taskArray: [Task]) {
        debugPrint(#function)

        if let realm = try? Realm() {
            // First remove from categories
            taskArray.forEach { task in
                do {
                    try realm.write {
                        task.removeTaskFromCategoryList(segment: task.segment)
                        task.removeTaskFromCategoryList(segment: CategorySelections.allDay.rawValue)
                    }
                } catch {
                    realm.cancelWrite()
                }
            }

            // Thene delete the tasks
            do {
                try realm.write {
                    realm.delete(taskArray)
                }
            } catch {
                realm.cancelWrite()
            }
        }
    }

    // MARK: - Notification Handling

    // MUST be called from within a realm write operation
    private func moveTaskCategory(fromSegment: Int, toSegment: Int) {
        removeTaskFromCategoryList(segment: fromSegment)
        TaskCategory.returnTaskCategory(toSegment).taskList.append(self)
    }

    func snooze(function: String = #function) {
        debugPrint(#function + " called by " + function)
        if let realm = try? Realm() {
            do {
                try realm.write {
                    self.dateModified = Date()
                    moveTaskCategory(fromSegment: segment, toSegment: snoozeToInt())
                    self.segment = snoozeToInt()
                }
            } catch {
                realm.cancelWrite()
            }
            notificationHanlder.createNewNotification(forTask: self)
            debugPrint("Snoozing to \(segment). Original segment was \(originalSegment)")
        }
    }

    fileprivate func snoozeToInt(function: String = #function) -> Int {
        debugPrint(#function + " called by " + function)
        return Options.getNextSegmentFromTime()
    }

    func moveToNextSegment() {
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                if let realm = try? Realm() {
                    do {
                        try realm.write {
                            switch self.segment {
                            case 3:
                                moveTaskCategory(fromSegment: segment, toSegment: 0)
                                self.segment = 0
                            default:
                                moveTaskCategory(fromSegment: segment, toSegment: self.segment + 1)
                                self.segment += 1
                            }
                        }
                    } catch {
                        realm.cancelWrite()
                    }
                }
            }
        }
    }

    func setDailyRepeat(_ bool: Bool) {
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                if let realm = try? Realm() {
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
    }

    static func getCountForSegment(segment: Int) -> Int {
        var count = 0
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                if let realm = try? Realm() {
                    count = realm.objects(Task.self).filter("segment = \(segment)").count
                }
            }
        }
        return count
    }

    static func getTaskCount() -> Int {
        var count = 0
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                if let realm = try? Realm() {
                    count = realm.objects(Task.self).count
                }
            }
        }
        return count
    }
}
