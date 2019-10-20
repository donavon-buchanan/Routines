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
                let realm = try! Realm()
                let items = realm.objects(Task.self)
                do {
                    try realm.write {
                        realm.delete(items)
                    }
                } catch {
                    realm.cancelWrite()
                }
            }
        }

        let item1 = Task(title: "Walk the dogs 🐕", segment: 0, repeats: true, notes: nil)
        let item2 = Task(title: "Meditate 🧘‍♂️", segment: 0, repeats: true, notes: nil)
        let item3 = Task(title: "Find a healthy activity", segment: 0, repeats: true, notes: "🌻🌞🚲")
        let item5 = Task(title: "Figure out dinner plans", segment: 0, repeats: false, notes: nil)

        let item4 = Task(title: "Make a doctor's appointment", segment: 1, repeats: false, notes: nil)
        let item6 = Task(title: "Pick up dry cleaning", segment: 1, repeats: false, notes: nil)
        let item7 = Task(title: "Plan dad's birthday party", segment: 1, repeats: false, notes: """
        1. Order the cake 🎂
        2. Send out invitations 🥳🥳
        3. Get party decorations and supplies 🎈🎉
        """)

        let item8 = Task(title: "Buy groceries", segment: 2, repeats: false, notes: """
        - Coffee
        - Flour
        - Sugar
        """)
        let item9 = Task(title: "Water the plants 🌱", segment: 2, repeats: true, notes: nil)

        let item10 = Task(title: "Clean the kitchen", segment: 3, repeats: true, notes: nil)
        let item11 = Task(title: "Do the laundry", segment: 3, repeats: true, notes: nil)
        let item12 = Task(title: "Exercise your mind", segment: 3, repeats: true, notes: nil)

        let itemList = [item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12]

        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                // Subvert init logic for simulator
                // Otherwise these show up as tomorrow's tasks
                itemList.forEach { item in
                    item.completeUntil = Date()
                }

                itemList.forEach { task in
                    task.addNewItem()
                }
            }
        }
    #endif
}
