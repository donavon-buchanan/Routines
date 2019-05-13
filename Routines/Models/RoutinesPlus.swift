//
//  RoutinesPlus.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/12/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation
import IceCream
import RealmSwift

@objcMembers class RoutinesPlus: Object {
    
    static let realmDispatchQueueLabel: String = "background"
    
    dynamic var routinesPlusKey = UUID().uuidString
    override static func primaryKey() -> String {
        return "routinesPlusKey"
    }
    
    dynamic var routinesPlusPurchased: Bool = false
    dynamic var purchasedProduct: String = ""
    
    dynamic var cloudSync: Bool = false
    
    static func getCloudSync() -> Bool {
        var status = false
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
                status = routinesPlus?.cloudSync ?? false
            }
        }
        #if targetEnvironment(simulator)
        return true
        #else
        return status
        #endif
    }
    
    static func setCloudSync(toggle: Bool) {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
                do {
                    try realm.write {
                        routinesPlus?.cloudSync = toggle
                    }
                } catch {
                    fatalError("\(#function) - Failed to save cloudSync option. Error: \(error)")
                }
            }
        }
        
        AppDelegate.setSync()
    }
    
    static func getPurchasedStatus() -> Bool {
        var status = false
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
                status = routinesPlus?.routinesPlusPurchased ?? false
            }
        }
        #if targetEnvironment(simulator)
        return true
        #else
        return status
        #endif
    }
    
    static func setPurchasedStatus(status: Bool) {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
                do {
                    try realm.write {
                        routinesPlus?.routinesPlusPurchased = status
                    }
                } catch {
                    fatalError("\(#function) - Failed to set purchased status in routinesPlus with error: \(error)")
                }
            }
        }
    }
    
    static func setPurchasedProduct(productID: String) {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
                do {
                    try realm.write {
                        routinesPlus?.purchasedProduct = productID
                    }
                } catch {
                    fatalError("\(#function) - Error saving purchased product: \(error)")
                }
            }
        }
    }
    
    static func getPurchasedProduct() -> String {
        let realm = try! Realm()
        let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
        #if targetEnvironment(simulator)
        return ""
        #else
        return routinesPlus?.purchasedProduct ?? ""
        #endif
    }
}
