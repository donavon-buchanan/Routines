//
//  SimulatorData.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/21/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift

func loadDefaultData() {
    #if targetEnvironment(simulator)

        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                if let realm = try? Realm() {
                    let tasks = realm.objects(Task.self)
                    do {
                        try realm.write {
                            realm.delete(tasks)
                        }
                    } catch {
                        realm.cancelWrite()
                    }
                }
            }
        }

        let task1 = Task(title: "Walk the dogs 🐕", segment: 0, repeats: true, notes: nil)
        let task2 = Task(title: "Meditate 🧘‍♂️", segment: 0, repeats: true, notes: nil)
        let task3 = Task(title: "Find a healthy activity", segment: 0, repeats: true, notes: "🌻🌞🚲")
        let task5 = Task(title: "Figure out dinner plans", segment: 0, repeats: false, notes: nil)

        let task4 = Task(title: "Make a doctor's appointment", segment: 1, repeats: false, notes: nil)
        let task6 = Task(title: "Pick up dry cleaning", segment: 1, repeats: false, notes: nil)
        let task7 = Task(title: "Plan dad's birthday party", segment: 1, repeats: false, notes: """
        1. Order the cake 🎂
        2. Send out invitations 🥳🥳
        3. Get party decorations and supplies 🎈🎉
        """)

        let task8 = Task(title: "Buy groceries", segment: 2, repeats: false, notes: """
        - Coffee
        - Flour
        - Sugar
        """)
        let task9 = Task(title: "Water the plants 🌱", segment: 2, repeats: true, notes: nil)

        let task10 = Task(title: "Clean the kitchen", segment: 3, repeats: true, notes: nil)
        let task11 = Task(title: "Do the laundry", segment: 3, repeats: true, notes: nil)
        let task12 = Task(title: "Exercise your mind", segment: 3, repeats: true, notes: nil)

        let taskList = [task1, task2, task3, task4, task5, task6, task7, task8, task9, task10, task11, task12]

        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                // Subvert init logic for simulator
                // Otherwise these show up as tomorrow's tasks
                taskList.forEach { task in
                    task.completeUntil = Date()
                }

                taskList.forEach { task in
                    task.addNewTask()
                }
            }
        }
    #endif
}
