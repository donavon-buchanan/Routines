//
//  OptionsForTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 10/27/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

extension TableViewController {
    
//    func loadOptions() {
//        if let optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
//            self.optionsObject = optionsObject
//        } else {
//            let newOptions = Options()
//            newOptions.optionsKey = optionsKey
//            saveOptions(optionsObject: newOptions)
//            loadOptions()
//        }
//    }
    
//    //Load Options
//    func loadOptions() {
//        //optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey)
//
//        if let currentOptions = self.realm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
//            self.optionsObject = currentOptions
//            print("TableVC: Options loaded successfully - \(String(describing: optionsObject))")
//        } else {
//            print("TableVC: No Options exist yet. Creating it.")
//            let newOptionsObject = Options()
//            newOptionsObject.optionsKey = optionsKey
//            do {
//                try self.realm.write {
//                    self.realm.add(newOptionsObject, update: false)
//                }
//            } catch {
//                print("Failed to create new options object")
//            }
//            loadOptions()
//        }
//
//    }
    
//    //If the realm has items, set firstItemAdded to true
//    func checkIfFirstItemAdded() {
//        print("Checking for items.")
//        if let items = self.items {
//            print("Item count is \(items.count)")
//            if items.count > 0 {
//                do {
//                    try self.realm.write {
//                        self.optionsObject?.firstItemAdded = true
//                    }
//                } catch {
//                    fatalError("Options object failed to update")
//                }
//            }
//        }
//    }
    
    func saveOptions(optionsObject: Options) {
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        realm.add(optionsObject, update: true)
                    }
                } catch {
                    print("Failed to save option from TableViewController")
                }
            }
        }
    }

}
