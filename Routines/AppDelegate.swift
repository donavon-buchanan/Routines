//
//  AppDelegate.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        requestNotificationPermission()
        //checkToCreateOptions()
        loadOptions()
        
        

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    //MARK: - Options Realm
//    let realmDispatchQueueLabel: String = "background"
//
//    func checkToCreateOptions() {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                let options = realm.object(ofType: Options.self, forPrimaryKey: "optionsKey")
//                print("App Delegate - Options is: \(String(describing: options))")
//                if options == nil {
//                    let newOptions = Options()
//                    print("Creating Options for the first time with \(String(describing: newOptions))")
//                    do {
//                        try! realm.write {
//                            realm.add(newOptions)
//                        }
//                    }
//                } else {
//                    print("Options exist. Carry on.")
//                }
//            }
//        }
//    }
    
//
//    //Options Properties
    let realm = try! Realm()
    var optionsObject: Options?
    let optionsKey = "optionsKey"

    //Load Options
    func loadOptions() {
        optionsObject = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)

        if let currentOptions = realm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
            self.optionsObject = currentOptions
            print("AppDelegate: Options loaded successfully - \(String(describing: optionsObject))")
        } else {
            print("AppDelegate: No Options exist yet. Creating it.")
            let newOptionsObject = Options()
            newOptionsObject.optionsKey = optionsKey
            do {
                try realm.write {
                    realm.add(newOptionsObject, update: false)
                }
            } catch {
                print("Failed to create new options object")
            }
            loadOptions()
        }

    }
    
    //MARK: - Manage Notifications
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        //Request permission to display alerts and play sounds
        if #available(iOS 12.0, *) {
            center.requestAuthorization(options: [.alert, .sound, .badge, .provisional, .providesAppNotificationSettings]) { (granted, error) in
                // Enable or disable features based on authorization.
                if granted {
                    print("App Delegate: App has notification permission")
                } else {
                    print("App Delegate: App does not have notification permission")
                    return
                }
            }
        } else {
            // Fallback on earlier versions
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Enable or disable features based on authorization.
                if granted {
                    print("App Delegate: App has notification permission")
                } else {
                    print("App Delegate: App does not have notification permission")
                    return
                }
            }
        }
    }
    
    
    
}

