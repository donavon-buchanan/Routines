//
//  AppDelegate.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    let notificationHandler = NotificationHandler()

    var shortcutItemToProcess: UIApplicationShortcutItem?

//    var syncEngine: SyncEngine?

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return UIInterfaceOrientationMask.all
        default:
            return UIInterfaceOrientationMask.portrait
        }
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        debugPrint("\(#function) - Start")
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        AppDelegate.registerNotificationCategoriesAndActions()

        migrateRealm()

        AppDelegate.checkOptions()
        AppDelegate.checkRoutinesPlus()

        debugPrint("\(#function) - End")
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        debugPrint("\(#function) - Start")

        // Override point for customization after application launch.

//        application.registerForRemoteNotifications()

        // If launchOptions contains the appropriate launch options key, a Home screen quick action
        // is responsible for launching the app. Store the action for processing once the app has
        // completed initialization.
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            shortcutItemToProcess = shortcutItem
        }

        #if targetEnvironment(simulator)
            loadDefaultData()
        #endif

        var shortcutItems: [UIApplicationShortcutItem] = []
        let settingsShortcut = UIMutableApplicationShortcutItem(type: "SettingsAction", localizedTitle: "Settings")
        settingsShortcut.icon = UIApplicationShortcutIcon(systemImageName: "gear")
        shortcutItems.append(settingsShortcut)
        UIApplication.shared.shortcutItems = shortcutItems

        debugPrint("\(#function) - End")
        return true
    }

//    func application(_ application: UIApplication, performFetchWithCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {
//
//    }

//    func application(_ application: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any], fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {
//
//
//        debugPrint("Received push notification")
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        debugPrint("\(#function) - Start")

        notificationHandler.removeOrphanedNotifications()

        debugPrint("\(#function) - End")
    }

//    func applicationDidEnterBackground(_ application: UIApplication) {
//        debugPrint("\(#function) - Start")
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//
//        debugPrint("\(#function) - End")
//    }

    static func removeOldNotifications(function: String = #function) {
        debugPrint("\(#function) - Start")
        debugPrint("#funciton was Called from: \(function)")
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()

        DispatchQueue.main.async {
            autoreleasepool {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        debugPrint("\(#function) - End")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        debugPrint("\(#function) - Start")

        debugPrint("\(#function) - End")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        debugPrint("\(#function) - Start")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        if let shortcutItem = shortcutItemToProcess {
            if shortcutItem.type == "AddAction" {
                goToAdd()
            }
            if shortcutItem.type == "SettingsAction" {
                goToSettings()
            }
            shortcutItemToProcess = nil
        }
        
        AppDelegate.removeOldNotifications()
        notificationHandler.removeOrphanedNotifications()

        debugPrint("\(#function) - End")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        debugPrint("\(#function) - Start")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        notificationHandler.removeOrphanedNotifications()
        debugPrint("\(#function) - End")
    }

    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        true
    }

    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        true
    }

//    open func restoreSelectedTab(tab: Int?) {
//        let rootVC = window?.rootViewController as! UITabBarController
//        if let selectedTab = tab {
//            rootVC.selectedIndex = selectedTab
//        } else {
//            rootVC.selectedIndex = Options.getSelectedIndex()
//        }
//    }

    // MARK: - Options Realm

    static func checkOptions() {
        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) != nil {
                    debugPrint("Options exist. App should continue")
                } else {
                    debugPrint("Options DO NOT exist. Creating")
                    let newOptions = Options()
                    newOptions.optionsKey = Options.primaryKey()
                    do {
                        realm.beginWrite()
                        realm.add(newOptions)
                        try realm.commitWrite()
                    } catch {
                        realm.cancelWrite()
                    }
                }
            }
        }
    }

    static func checkRoutinesPlus() {
        DispatchQueue(label: RoutinesPlus.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey()) != nil {
                    debugPrint("RoutinesPlus exist. App should continue")
                } else {
                    debugPrint("RoutinesPlus DOES NOT exist. Creating")
                    let newRoutinesPlus = RoutinesPlus()
                    newRoutinesPlus.routinesPlusKey = RoutinesPlus.primaryKey()
                    do {
                        realm.beginWrite()
                        realm.add(newRoutinesPlus)
                        try realm.commitWrite()
                    } catch {
                        realm.cancelWrite()
                    }
                }
            }
        }
    }

    func migrateRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 28,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                debugPrint("oldSchemaVersion: \(oldSchemaVersion)")
                if oldSchemaVersion < 9 {
                    migration.enumerateObjects(ofType: Options.className()) { oldObject, newObject in
                        let morningStartTime = oldObject!["morningStartTime"] as! Date
                        let afternoonStartTime = oldObject!["afternoonStartTime"] as! Date
                        let eveningStartTime = oldObject!["eveningStartTime"] as! Date
                        let nightStartTime = oldObject!["nightStartTime"] as! Date

                        newObject!["morningHour"] = Options.getHour(date: morningStartTime)
                        newObject!["morningMinute"] = Options.getMinute(date: morningStartTime)

                        newObject!["afternoonHour"] = Options.getHour(date: afternoonStartTime)
                        newObject!["afternoonMinute"] = Options.getMinute(date: afternoonStartTime)

                        newObject!["eveningHour"] = Options.getHour(date: eveningStartTime)
                        newObject!["eveningMinute"] = Options.getMinute(date: eveningStartTime)

                        newObject!["nightHour"] = Options.getHour(date: nightStartTime)
                        newObject!["nightMinute"] = Options.getMinute(date: nightStartTime)
                    }
                }

                if oldSchemaVersion >= 9, oldSchemaVersion < 15 {
                    migration.enumerateObjects(ofType: Options.className()) { oldObject, newObject in
                        print("oldObject: " + String(describing: oldObject))
                        print("newObject: " + String(describing: newObject))
                    }
                    // TODO: !!! Task class name can't migrate because class name changed !!!
                    // TODO: Also, future migrations may conflict with iCloud
                    migration.enumerateObjects(ofType: "Items") { _, newObject in
                        // print("oldObject: " + String(describing: oldObject))
                        newObject!["isDeleted"] = false
                        newObject!["dateModified"] = Date()
                        newObject!["completeUntil"] = Date()
                        newObject!["repeats"] = true
                        // print("newObject: " + String(describing: newObject))
                    }
                }

                if oldSchemaVersion >= 15, oldSchemaVersion < 18 {
                    migration.enumerateObjects(ofType: "Items") { oldObject, newObject in
                        print("oldObject: " + String(describing: oldObject))
                        print("newObject: " + String(describing: newObject))
                        let originalSegment = oldObject!["segment"] as! Int
                        newObject!["originalSegment"] = originalSegment
                    }
                }

                if oldSchemaVersion >= 18, oldSchemaVersion < 21 {
                    // migrate the Options split to RoutinesPlus

                    migration.enumerateObjects(ofType: Options.className()) { oldObject, newObject in
                        debugPrint("oldObject: \(String(describing: oldObject))")
                        debugPrint("newObject: \(String(describing: newObject))")

                        let cloudSync = oldObject!["cloudSync"] as! Bool
                        UserDefaults.standard.set(cloudSync, forKey: "cloudSync")

                        let newRoutinesPlus = RoutinesPlus()

                        newRoutinesPlus.routinesPlusKey = RoutinesPlus.primaryKey()

                        migration.create("RoutinesPlus", value: newRoutinesPlus)
                    }
                }

                if oldSchemaVersion >= 21, oldSchemaVersion <= 25 {
                    // First, create the new category objects
                    let morningCategory = migration.create("TaskCategory", value: TaskCategory(category: 0))
                    let afternoonCategory = migration.create("TaskCategory", value: TaskCategory(category: 1))
                    let eveningCategory = migration.create("TaskCategory", value: TaskCategory(category: 2))
                    let nightCategory = migration.create("TaskCategory", value: TaskCategory(category: 3))
                    let allCategory = migration.create("TaskCategory", value: TaskCategory(category: 4))

                    var morningList = [MigrationObject]()
                    var afternoonList = [MigrationObject]()
                    var eveningList = [MigrationObject]()
                    var nightList = [MigrationObject]()
                    var allList = [MigrationObject]()

                    migration.enumerateObjects(ofType: RoutinesPlus.className()) { _, _ in
                        // auto migration
                    }
                    migration.enumerateObjects(ofType: Options.className()) { _, _ in
                        // auto migration
                    }
                    migration.enumerateObjects(ofType: "Items") { oldObject, _ in
                        //First check if the old Item was marked for deletion
                        if oldObject!["isDeleted"] as! Bool == false {
                            // Create a new task from the old object
                            let newTask = migration.create(Task.className(), value: oldObject!)
                            debugPrint("newTask: " + String(describing: newTask))
                            /*
                             Based on the segment of that task, append it to the appropriate
                             array of tasks associated with the categories above
                             */
                            switch newTask["segment"] as! Int {
                            case 1:
                                debugPrint("adding newTask to afternoon: " + String(describing: newTask))
                                afternoonList.append(newTask)
                            case 2:
                                debugPrint("adding newTask to evening: " + String(describing: newTask))
                                eveningList.append(newTask)
                            case 3:
                                debugPrint("adding newTask to night: " + String(describing: newTask))
                                nightList.append(newTask)
                            default:
                                debugPrint("adding newTask to morning: " + String(describing: newTask))
                                morningList.append(newTask)
                            }
                            // Also add each task to the array for allList
                            debugPrint("adding newTask to all: " + String(describing: newTask))
                            allList.append(newTask)
                        } else {
                            // If "isDeleted" was true, delete the old object from the realm
                            migration.delete(oldObject!)
                        }
                        
                    }

                    // Finally, append sequence in reversed order to the category lists so it appears as the user previously had them sorted
                    /*
                     Note: This didn't work during my initial testing, which worries me still. But after re-writing all of this, it seems fine.
                     Previously, it produced a ton of duplicate tasks, progressively getting worse as the enumeration continued.
                     */
                    morningCategory.dynamicList("taskList").append(objectsIn: morningList.reversed())
                    afternoonCategory.dynamicList("taskList").append(objectsIn: afternoonList.reversed())
                    eveningCategory.dynamicList("taskList").append(objectsIn: eveningList.reversed())
                    nightCategory.dynamicList("taskList").append(objectsIn: nightList.reversed())
                    allCategory.dynamicList("taskList").append(objectsIn: allList.reversed())
                }

                if oldSchemaVersion > 25, oldSchemaVersion <= 27 {
                    migration.enumerateObjects(ofType: "Task") { oldObject, _ in
                        // auto migration for property rename or change
                        // also a little cleanup for TestFlight users
                        
                        if oldObject!["isDeleted"] as! Bool == true {
                            migration.delete(oldObject!)
                        }
                    }
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try? Realm()
    }

    func completeTask(uuidString: String) {
        if let realm = try? Realm() {
            guard let task = realm.object(ofType: Task.self, forPrimaryKey: uuidString) else { return }

            task.completeTask()
        }
    }

    func snoozeTask(uuidString: String) {
        if let realm = try? Realm() {
            guard let task = realm.object(ofType: Task.self, forPrimaryKey: uuidString) else { return }

            task.snooze()
        }
    }

    deinit {
        debugPrint("\(#function) called. Tokens invalidated")
    }

    // MARK: - Notification Categories and Actions

    static func registerNotificationCategoriesAndActions() {
        let center = UNUserNotificationCenter.current()

        let completeAction = UNNotificationAction(identifier: "complete", title: "Completed", options: UNNotificationActionOptions(rawValue: 0))

        let snoozeAction = UNNotificationAction(identifier: "snooze", title: "Notify Me Later", options: UNNotificationActionOptions(rawValue: 0))

        let morningSummaryFormat = "%u more Morning tasks"
        let morningPreviewPlaceholder = "%u Morning tasks"

        let afternoonSummaryFormat = "%u more Afternoon tasks"
        let afternoonPreviewPlaceholder = "%u Afternoon tasks"

        let eveningSummaryFormat = "%u more Evening tasks"
        let eveningPreviewPlaceholder = "%u Evening tasks"

        let nightSummaryFormat = "%u more Night tasks"
        let nightPreviewPlaceholder = "%u Night tasks"

        let morningCategory = UNNotificationCategory(identifier: "morning", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: morningPreviewPlaceholder, categorySummaryFormat: morningSummaryFormat, options: [])

        let afternoonCategory = UNNotificationCategory(identifier: "afternoon", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: afternoonPreviewPlaceholder, categorySummaryFormat: afternoonSummaryFormat, options: [])

        let eveningCategory = UNNotificationCategory(identifier: "evening", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: eveningPreviewPlaceholder, categorySummaryFormat: eveningSummaryFormat, options: [])

        let nightCategory = UNNotificationCategory(identifier: "night", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nightPreviewPlaceholder, categorySummaryFormat: nightSummaryFormat, options: [])

        center.setNotificationCategories([morningCategory, afternoonCategory, eveningCategory, nightCategory])
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "complete":
            completeTask(uuidString: response.notification.request.identifier)
            decrementBadge()
        case "snooze":
            snoozeTask(uuidString: response.notification.request.identifier)
            decrementBadge()
        default:
            guard let realm = try? Realm() else { break }
            if let task = realm.object(ofType: Task.self, forPrimaryKey: response.notification.request.identifier) {
                switch task.segment {
                case 1:
                    self.presentStoryboardView(withIdentifier: "afternoonNavigationController")
                case 2:
                    self.presentStoryboardView(withIdentifier: "eveningNavigationController")
                case 3:
                    self.presentStoryboardView(withIdentifier: "nightNavigationController")
                default:
                    self.presentStoryboardView(withIdentifier: "morningNavigationController")
                }
            } else {
                break
            }
        }

        completionHandler()
    }

    func decrementBadge() {
        let currentBadgeNumber = UIApplication.shared.applicationIconBadgeNumber
        if currentBadgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
    }

    static func updateBadgeFromPush() {
        debugPrint(#function)
        debugPrint("updating badge from remote push")
        let center = UNUserNotificationCenter.current()
        var remoteBadge = 0
        center.getDeliveredNotifications { deliveredNotifications in
            remoteBadge = deliveredNotifications.count
        }
        UIApplication.shared.applicationIconBadgeNumber = remoteBadge
    }

    fileprivate func presentStoryboardView(withIdentifier identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vcToPresent = storyBoard.instantiateViewController(withIdentifier: identifier)
        let topController = UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.rootViewController
        // Dismiss if there's another view already on top
        topController?.dismiss(animated: true, completion: nil)
        topController?.present(vcToPresent, animated: true, completion: nil)
    }
    
    fileprivate func makeStoryboardViewKey(withIdentifier identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vcToPresent = storyBoard.instantiateViewController(withIdentifier: identifier)
        var topController = UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.rootViewController
        // Dismiss if there's another view already on top
        topController?.dismiss(animated: true, completion: nil)
        topController = vcToPresent
    }

    // Notification Settings Screen
    fileprivate func goToSettings() {
        presentStoryboardView(withIdentifier: "settingsNavigationController")
    }

    fileprivate func goToAdd() {
        presentStoryboardView(withIdentifier: "addEditNavigationController")
    }

    func userNotificationCenter(_: UNUserNotificationCenter, openSettingsFor _: UNNotification?) {
        goToSettings()
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler _: @escaping (Bool) -> Void) {
        shortcutItemToProcess = shortcutItem
    }

    func getTaskSegment(id: String) -> Int {
        var identifier: String {
            if id.count > 36 {
                return String(id.dropLast())
            } else {
                return id
            }
        }
        var segment = Int()
        DispatchQueue(label: Task.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let task = realm.object(ofType: Task.self, forPrimaryKey: identifier) {
                    segment = task.segment
                }
            }
        }
        return segment
    }

    func getNotificationSegment(id: String) -> Int {
        var segment: Int {
            // If it's an auto snooze notification, just get the last character as an Int and go to that segment
            if id.count > 36 {
                return Int(String(id.last!)) ?? 0
            } else {
                // If it's not auto snooze, need to fetch the segment property of the task
                return getTaskSegment(id: id)
            }
        }
        return segment
    }
}
