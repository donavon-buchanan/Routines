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
    
    //Load Options
    func loadOptions() {
        if let optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
            self.optionsObject = optionsObject
        } else {
            let newOptions = Options()
            newOptions.optionsKey = optionsKey
            saveOptions(optionsObject: newOptions)
            loadOptions()
        }
    }
    
    //If the realm has items, set firstItemAdded to true
    func checkIfFirstItemAdded() {
        print("Checking for items.")
        if let items = self.items {
            print("Item count is \(items.count)")
            if items.count > 0 {
                do {
                    try self.optionsRealm.write {
                        self.optionsObject?.firstItemAdded = true
                    }
                } catch {
                    fatalError("Options object failed to update")
                }
            }
        }
    }
    
    func saveOptions(optionsObject: Options) {
        //guard let options = self.optionsObject else { fatalError() }
        
        do {
            try self.optionsRealm.write {
                optionsRealm.add(optionsObject, update: true)
            }
        } catch {
            print("Failed to save option from TableViewController")
        }
    }

}
