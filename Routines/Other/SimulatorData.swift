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
    #if !targetEnvironment(simulator)
        return
    #endif

    DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
        autoreleasepool {
            let realm = try! Realm()
            let items = realm.objects(Items.self)
            do {
                try realm.write {
                    realm.delete(items)
                }
            } catch {
                fatalError("Simulator failed to delete items with error: \(error)")
            }
        }
    }

    let item1 = Items(title: "Walk the dogs 🐕", segment: 0, priority: 0, repeats: true, notes: nil)
    let item2 = Items(title: "Meditate 🧘‍♂️", segment: 0, priority: 0, repeats: true, notes: nil)
    let item3 = Items(title: "Do something healthy", segment: 0, priority: 0, repeats: true, notes: "🌻🌞🚲")
    let item4 = Items(title: "Make a doctor's appointment", segment: 0, priority: 0, repeats: false, notes: nil)

    let item5 = Items(title: "Figure out dinner plans", segment: 1, priority: 0, repeats: false, notes: nil)
    let item6 = Items(title: "Pick up dry cleaning", segment: 1, priority: 0, repeats: false, notes: nil)
    let item7 = Items(title: "Plan dad's birthday party", segment: 1, priority: 0, repeats: false, notes: """
    1. Order the cake 🎂
    2. Send out invitations 🥳🥳
    3. Get party decorations and supplies 🎈🎉
    """)

    let item8 = Items(title: "Buy groceries", segment: 2, priority: 0, repeats: false, notes: """
    - Coffee
    - Flour
    - Sugar
    """)
    let item9 = Items(title: "Water the plants 🌱", segment: 2, priority: 0, repeats: true, notes: nil)

    let item10 = Items(title: "Clean the kitchen", segment: 3, priority: 0, repeats: true, notes: nil)
    let item11 = Items(title: "Do the laundry", segment: 3, priority: 0, repeats: true, notes: nil)
    let item12 = Items(title: "Exercise your mind", segment: 3, priority: 0, repeats: true, notes: nil)

    let itemList = [item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12]

    DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
        autoreleasepool {
            // Subvert init logic for simulator
            // Otherwise these show up as tomorrow's tasks
            itemList.forEach { item in
                item.completeUntil = Date()
            }

            let realm = try! Realm()
            do {
                realm.beginWrite()
                realm.add(itemList)
                try realm.commitWrite()
            } catch {
                fatalError("Simulator failed to add list of items with error: \(error)")
            }
        }
    }
}
