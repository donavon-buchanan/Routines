//
//  TaskCategory.swift
//  Routines
//
//  Created by Donavon Buchanan on 10/15/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

// import IceCream
import RealmSwift

// Morning = 0
// Afternoon = 1
// Evening = 2
// Night = 3
// All = 4
// Complete = 5

enum CategorySelections: Int {
    case morning, afternoon, evening, night, allDay, completed
}

@objcMembers class TaskCategory: Object {
    dynamic var isDeleted: Bool = false
    dynamic var id: String?
    override static func primaryKey() -> String? {
        "id"
    }

    dynamic var categoryInt = 0

    let taskList = List<Task>()

    required convenience init(category: Int) {
        self.init()
        categoryInt = category
        id = String(category)
    }

    // Convenience function to return category object if it exist. If not, create it and return it
    static func returnTaskCategory(_ category: Int) -> TaskCategory {
        if let realm = try? Realm() {
            if let taskCategory = realm.object(ofType: TaskCategory.self, forPrimaryKey: String(category)) {
                // If it exist, return it
                debugPrint("Category object for \(category) exist. Returning")
                return taskCategory
            } else {
                // Else, create it, then return it
                debugPrint("Category object for \(category) does not exist yet. Creating then returning")
                do {
                    if realm.isInWriteTransaction {
                        let newTaskCategory = TaskCategory(category: category)
                        realm.add(newTaskCategory)
                    } else {
                        try realm.write {
                            let newTaskCategory = TaskCategory(category: category)
                            realm.add(newTaskCategory)
                        }
                    }
                } catch {
                    realm.cancelWrite()
                }
                return returnTaskCategory(category)
            }
        } else {
            return returnTaskCategory(category)
        }
    }
}

// extension TaskCategory: CKRecordConvertible {
//    // Yep, leave it blank!
// }
//
// extension TaskCategory: CKRecordRecoverable {
//    // Leave it blank, too.
// }
