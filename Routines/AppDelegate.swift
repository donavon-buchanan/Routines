//
//  AppDelegate.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import CloudKit
import IceCream
import RealmSwift
// import SwiftTheme
// import SwiftyStoreKit
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    let notificationHandler = NotificationHandler()

//    static let automaticDarkModeTimer = AutomaticDarkModeTimer()

//    static func setAutomaticDarkModeTimer() {
//        if Options.getAutomaticDarkModeStatus() {
//            automaticDarkModeTimer.startTimer()
//        } else {
//            automaticDarkModeTimer.stopTimer()
//        }
//    }

    var shortcutItemToProcess: UIApplicationShortcutItem?

    static var syncEngine: SyncEngine?

    func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return UIInterfaceOrientationMask.all
        default:
            return UIInterfaceOrientationMask.portrait
        }
    }

    // TODO: This should be used way less. Make notification management on individual tasks better!
//    static func refreshNotifications(function: String = #function) {
//        printDebug(#function + "Called by \(function)")
//
//        let notificationHandler = NotificationHandler()
//        notificationHandler.removeOrphanedNotifications()
//
//        let realm = try! Realm()
//        let items = realm.objects(Task.self).filter("isDeleted = %@", false).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
//        items.forEach { item in
//            notificationHandler.createNewNotification(forItem: item)
//        }
//    }

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        printDebug("\(#function) - Start")
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        AppDelegate.registerNotificationCategoriesAndActions()

        migrateRealm()

        // I thought this would be needed. But it seems there's already another func to take care of this.
//        if UserDefaults.standard.bool(forKey: "notificationsHaveRefreshed") {
//            let notificationHandler = NotificationHandler()
//            notificationHandler.refreshAllNotifications()
//            UserDefaults.standard.set(true, forKey: "notificationsHaveRefreshed")
//        }

        AppDelegate.checkOptions()
        AppDelegate.checkRoutinesPlus()

        // Theme
//        setUpTheme()

//        Options.automaticDarkModeCheck()

        printDebug("\(#function) - End")
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        printDebug("\(#function) - Start")

        // Override point for customization after application launch.

        application.registerForRemoteNotifications()

        // If launchOptions contains the appropriate launch options key, a Home screen quick action
        // is responsible for launching the app. Store the action for processing once the app has
        // completed initialization.
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            shortcutItemToProcess = shortcutItem
        }

//        // SwiftyStoreKit
//        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
//            for purchase in purchases {
//                switch purchase.transaction.transactionState {
//                case .purchased, .restored:
//                    if purchase.needsFinishTransaction {
//                        SwiftyStoreKit.finishTransaction(purchase.transaction)
//                    }
//                    // Unlock content
//                    RoutinesPlus.setPurchasedStatus(status: true)
//                case .failed, .purchasing, .deferred:
//                    break // do nothing
//                @unknown default:
//                    break
//                }
//            }
//        }

        observeItems()
        observeOptions()
        #if targetEnvironment(simulator)
            loadDefaultData()
        #endif

        var shortcutItems: [UIApplicationShortcutItem] = []
        let settingsShortcut = UIMutableApplicationShortcutItem(type: "SettingsAction", localizedTitle: "Settings")
        settingsShortcut.icon = UIApplicationShortcutIcon(systemImageName: "gear")
        shortcutItems.append(settingsShortcut)
        UIApplication.shared.shortcutItems = shortcutItems

        printDebug("\(#function) - End")
        return true
    }

    func application(_: UIApplication, performFetchWithCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {
        observeItems()
        observeOptions()

//        AppDelegate.syncEngine?.pull(completionHandler: { error in
//            if let error = error {
//                printDebug("Error with sync pull: \(error)")
//                completionHandler(.failed)
//            } else {
//                completionHandler(.newData)
//            }
//        })
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)

        if let subscriptionID = notification?.subscriptionID, IceCreamSubscription.allIDs.contains(subscriptionID) {
            NotificationCenter.default.post(name: Notifications.cloudKitDataDidChangeRemotely.name, object: nil, userInfo: userInfo)
        }

        observeItems()
        observeOptions()

//        AppDelegate.syncEngine?.pull(completionHandler: { error in
//            if let error = error {
//                printDebug("Error with sync pull: \(error)")
//                completionHandler(.failed)
//            } else {
//                completionHandler(.newData)
//            }
//        })

        printDebug("Received push notification")
    }

    func applicationWillResignActive(_: UIApplication) {
        printDebug("\(#function) - Start")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        AppDelegate.automaticDarkModeTimer.stopTimer()

//        AppDelegate.syncEngine?.pushAll()

        func applicationWillResignActive(_: UIApplication) {
            //
        }

        printDebug("\(#function) - End")
    }

    func applicationDidEnterBackground(_: UIApplication) {
        printDebug("\(#function) - Start")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        AppDelegate.syncEngine?.pushAll()

        observeItems()
        observeOptions()
        notificationHandler.removeOrphanedNotifications()

        printDebug("\(#function) - End")
    }

    static func removeOldNotifications(function: String = #function) {
        printDebug("\(#function) - Start")
        debugPrint("#funciton was Called from: \(function)")
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()

        DispatchQueue.main.async {
            autoreleasepool {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        printDebug("\(#function) - End")
    }

    func applicationWillEnterForeground(_: UIApplication) {
        printDebug("\(#function) - Start")

        // Sync with iCloud
        observeItems()
        observeOptions()

        printDebug("\(#function) - End")
    }

    func applicationDidBecomeActive(_: UIApplication) {
        printDebug("\(#function) - Start")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppDelegate.setSync()

        if let shortcutItem = shortcutItemToProcess {
            if shortcutItem.type == "AddAction" {
                goToAdd()
            }
            if shortcutItem.type == "SettingsAction" {
                goToSettings()
            }
            shortcutItemToProcess = nil
        }

//        AppDelegate.setAutomaticDarkModeTimer()
        printDebug("\(#function) - End")
    }

//    static func removeOrphanedNotifications() {
//        printDebug("\(#function) - Start")
//        let center = UNUserNotificationCenter.current()
//        var orphanNotifications: [String] = []
//        center.getPendingNotificationRequests(completionHandler: { pendingNotifications in
//            pendingNotifications.forEach { notification in
//                let id = notification.identifier
//                let realm = try! Realm()
//                let item = realm.object(ofType: Task.self, forPrimaryKey: id)
//                // First test nil for items that don't exist
//                if item == nil {
//                    orphanNotifications.append(id)
//                } else if let item = item {
//                    // Next test if item is valid, but marked for deletion
//                    if item.isDeleted {
//                        orphanNotifications.append(id)
//                    }
//                }
//            }
//        })
//        center.removePendingNotificationRequests(withIdentifiers: orphanNotifications)
//        printDebug("\(#function) - End")
//    }

    func applicationWillTerminate(_: UIApplication) {
        printDebug("\(#function) - Start")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        notificationHandler.removeOrphanedNotifications()
        printDebug("\(#function) - End")
    }

    func application(_: UIApplication, shouldSaveApplicationState _: NSCoder) -> Bool {
        true
    }

    func application(_: UIApplication, shouldRestoreApplicationState _: NSCoder) -> Bool {
        true
    }

    open func restoreSelectedTab(tab: Int?) {
        let rootVC = window?.rootViewController as! UITabBarController
        if let selectedTab = tab {
            rootVC.selectedIndex = selectedTab
        } else {
            rootVC.selectedIndex = Options.getSelectedIndex()
        }
    }

//    func getSelectedTab() -> Int {
//        var selectedIndex = 0
//        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                    selectedIndex = options.selectedIndex
//                }
//            }
//        }
//        return selectedIndex
//    }

    // MARK: - Options Realm

    static func checkOptions() {
        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) != nil {
                    printDebug("Options exist. App should continue")
                } else {
                    printDebug("Options DO NOT exist. Creating")
                    let newOptions = Options()
                    newOptions.optionsKey = Options.primaryKey()
                    do {
                        try realm.write {
                            realm.add(newOptions)
                        }
                    } catch {
                        fatalError("Failed to create first Options object: \(error)")
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
                    printDebug("RoutinesPlus exist. App should continue")
                } else {
                    printDebug("RoutinesPlus DOES NOT exist. Creating")
                    let newRoutinesPlus = RoutinesPlus()
                    newRoutinesPlus.routinesPlusKey = RoutinesPlus.primaryKey()
                    do {
                        try realm.write {
                            realm.add(newRoutinesPlus)
                        }
                    } catch {
                        fatalError("Failed to create first RoutinesPlus object: \(error)")
                    }
                }
            }
        }
    }

    func migrateRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 27,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                printDebug("oldSchemaVersion: \(oldSchemaVersion)")
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

//                if oldSchemaVersion < 10 {
//                    migration.enumerateObjects(ofType: Options.className()) { newObject, oldObject in
//                        print("oldObject: " + String(describing: oldObject))
//                        print("newObject: " + String(describing: newObject))
//                    }
//                }

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

//                        let purchasedProduct = oldObject!["purchasedProduct"] as! String
//
//                        let routinesPlusPurchased = oldObject!["routinesPlusPurchased"] as! Bool

                        let newRoutinesPlus = RoutinesPlus()

                        newRoutinesPlus.routinesPlusKey = RoutinesPlus.primaryKey()
//                        newRoutinesPlus.purchasedProduct = purchasedProduct
//                        newRoutinesPlus.routinesPlusPurchased = routinesPlusPurchased

                        migration.create("RoutinesPlus", value: newRoutinesPlus)
                    }
                }

                if oldSchemaVersion >= 21, oldSchemaVersion <= 25 {
                    
                    migration.create("TaskCategory", value: TaskCategory(category: 0))
                    migration.create("TaskCategory", value: TaskCategory(category: 1))
                    migration.create("TaskCategory", value: TaskCategory(category: 2))
                    migration.create("TaskCategory", value: TaskCategory(category: 3))
                    
                    migration.enumerateObjects(ofType: RoutinesPlus.className()) { oldObject, _ in
                        //auto migration
                    }
                    migration.enumerateObjects(ofType: Options.className()) { (_, _) in
                        // auto migration
                    }
                    migration.enumerateObjects(ofType: "Items") { oldObject, _ in
                        let newTask = Task(title: oldObject!["title"] as! String, segment: oldObject!["segment"] as! Int, repeats:  oldObject!["repeats"] as! Bool, notes:  oldObject!["notes"] as? String)
                        migration.create("Task", value: newTask)
                    }
                }
                
                if oldSchemaVersion > 25, oldSchemaVersion <= 26 {
                    migration.enumerateObjects(ofType: "Task") { (_, _) in
                        //auto
                    }
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
    }

    func completeItem(uuidString: String) {
        let realm = try! Realm()
        guard let item = realm.object(ofType: Task.self, forPrimaryKey: uuidString) else { return }

        item.completeItem()
    }

    func snoozeItem(uuidString: String) {
        let realm = try! Realm()
        guard let item = realm.object(ofType: Task.self, forPrimaryKey: uuidString) else { return }

        item.snooze()
    }

    static func setSync() {
        printDebug(#function)
        if RoutinesPlus.getCloudSync() {
            // Setting this each time was causing the list of items to trigger a change in observation tokens
            // Only needs to be set if it isn't already
            guard AppDelegate.syncEngine == nil else { return }
            printDebug("Enabling cloud syncEngine")

            AppDelegate.syncEngine = SyncEngine(objects: [
                SyncObject<Task>(),
                SyncObject<Options>(),
            ], databaseScope: .private)
        } else {
            printDebug("Disabling cloud syncEngine")
            AppDelegate.syncEngine = nil
        }
    }

    // MARK: - Update after Notifications

    var itemsToken: NotificationToken?
    var optionsToken: NotificationToken?
    var items: Results<Task>?
    var options: Options?

    // TODO: This creates some redudancies with notification creation and deletion as handled by the Items class.
    func observeItems(function: String = #function) {
        printDebug(#function + "Called by \(function)")
        // Observe Results Notifications
        guard itemsToken == nil else { return }
        let notificationHandler = NotificationHandler()
        let realm = try! Realm()
        items = realm.objects(Task.self)
        // TODO: https://realm.io/docs/swift/latest/#interface-driven-writes
        // Observe Results Notifications
        itemsToken = items?.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                notificationHandler.removeOrphanedNotifications()
                notificationHandler.checkForMissingNotifications()
            case let .update(_, _, insertions, modifications):
                printDebug("updated items detected")
                // Caused crashes because deleted items don't exist and can't provide a property value
                // notificationHandler.removeNotifications(withIdentifiers: deletions.map { (self.items?[$0].uuidString) ?? ""})
                // These are being called too much because the order of the list is changing
                notificationHandler.removeOrphanedNotifications()
                debugPrint(#function + "Item Insertions: \(insertions.map { (self.items?[$0].title!) }) ")
                notificationHandler.batchModifyNotifications(items: insertions.map { (self.items?[$0]) })
                debugPrint(#function + "Item Modifications: \(modifications.map { (self.items?[$0].title!) }) ")
                notificationHandler.batchModifyNotifications(items: modifications.map { (self.items?[$0]) })
            case let .error(error):
                // An error occurred while opening the Realm file on the background worker thread
                printDebug("Error in \(#function) - \(error)")
            }
        }
    }

    func observeOptions(function: String = #function) {
        printDebug(#function + "Called by \(function)")
        guard optionsToken == nil else { return }
        let realm = try! Realm()
        let notificationHandler = NotificationHandler()
        if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
            optionsToken = options.observe { change in
                switch change {
                case let .change(properties):
                    properties.forEach { property in
                        debugPrint("Changed options property is \(property.name)")
                        if property.name.contains("Minute") || property.name.contains("Hour") {
                            //this is being called too much because of sync
                            printDebug("Notification times changed. Recreating notifications as necessary.")
                            notificationHandler.refreshAllNotifications()
                        }
                    }
                case let .error(error):
                    debugPrint("An error occurred: \(error)")
                case .deleted:
                    debugPrint("Options was deleted.")
                }
            }
        }
    }

//    static func refreshAndUpdate(function: String = #function) {
//        printDebug(#function + "Called by \(function)")
//        let notificationHandler = NotificationHandler()
//        notificationHandler.refreshAllNotifications()
//        AppDelegate.updateBadgeFromPush()
//        // AppDelegate.removeOrphanedNotifications()
//    }

//    @objc func backgroundRefresh() {
//        printDebug(#function)
//        refreshAndUpdate()
//    }

    deinit {
        printDebug("\(#function) called. Tokens invalidated")
        itemsToken?.invalidate()
        optionsToken?.invalidate()
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
            completeItem(uuidString: response.notification.request.identifier)
            decrementBadge()
        case "snooze":
            snoozeItem(uuidString: response.notification.request.identifier)
            decrementBadge()
        default:
            restoreSelectedTab(tab: getNotificationSegment(id: response.notification.request.identifier))
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
        printDebug(#function)
        printDebug("updating badge from remote push")
        let center = UNUserNotificationCenter.current()
        var remoteBadge = 0
        center.getDeliveredNotifications { deliveredNotifications in
            remoteBadge = deliveredNotifications.count
        }
        UIApplication.shared.applicationIconBadgeNumber = remoteBadge
    }

    fileprivate func presentStoryboardView(withIdentifier identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        let topController = UIApplication.shared.windows.first?.rootViewController
        // Dismiss if there's another view already on top
        topController?.dismiss(animated: true, completion: nil)
        topController?.present(addViewController, animated: true, completion: nil)
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

    func application(_: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler _: @escaping (Bool) -> Void) {
        // Alternatively, a shortcut item may be passed in through this delegate method if the app was
        // still in memory when the Home screen quick action was used. Again, store it for processing.
        shortcutItemToProcess = shortcutItem
    }

    func getItemSegment(id: String) -> Int {
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
                if let item = realm.object(ofType: Task.self, forPrimaryKey: identifier) {
                    segment = item.segment
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
                // If it's not auto snooze, need to fetch the segment property of the item
                return getItemSegment(id: id)
            }
        }
        return segment
    }

    // MARK: - Themes

//    func setUpTheme() {
    ////        window?.theme_backgroundColor = GlobalPicker.backgroundColor
//
//        // tab bar
//        let tabBar = UITabBar.appearance()
//        tabBar.theme_tintColor = GlobalPicker.barTextColor
//        tabBar.theme_barStyle = GlobalPicker.barStyle
//        tabBar.theme_barTintColor = GlobalPicker.tabBarTintColor
//        tabBar.backgroundImage = UIImage()
//        tabBar.theme_backgroundColor = GlobalPicker.backgroundColor
//        tabBar.shadowImage = UIImage()
//
//        // Themes.restoreLastTheme()
//
//        // status bar
//
    ////        UIApplication.shared.theme_setStatusBarStyle([.default, .default, .default, .default, .lightContent, .lightContent, .lightContent, .lightContent, .lightContent], animated: true)
//
//        // navigation bar
//
    ////        let navigationBar = UINavigationBar.appearance()
    ////        navigationBar.theme_barStyle = GlobalPicker.barStyle
    ////        navigationBar.theme_tintColor = GlobalPicker.barTextColor
    ////        navigationBar.shadowImage = UIImage()
//        // isTranslucent false seems to cause a layout bug
//
    ////        let shadow = NSShadow()
    ////        shadow.shadowOffset = CGSize(width: 0, height: 0)
    ////
    ////        let titleAttributes = GlobalPicker.barTextColors.map { hexString in
    ////            [
    ////                NSAttributedString.Key.foregroundColor: UIColor(rgba: hexString),
    ////                // NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
    ////
    ////                NSAttributedString.Key.shadow: shadow,
    ////            ]
    ////        }
    ////
    ////        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)
    ////        navigationBar.theme_largeTitleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)
//
//        // Cells
    ////        let cell = UITableViewCell.appearance()
    ////        cell.theme_backgroundColor = GlobalPicker.barTintColor
    ////        cell.theme_tintColor = GlobalPicker.barTextColor
    ////
    ////        // TableView
    ////        let tableViewUI = UITableView.appearance()
    ////        tableViewUI.theme_separatorColor = GlobalPicker.cellSeparator
    ////        //tableViewUI.theme_backgroundColor = GlobalPicker.cellBackground
    ////
    ////        // switches
    ////        let switchUI = UISwitch.appearance()
    ////        switchUI.theme_onTintColor = GlobalPicker.switchTintColor
    ////        switchUI.theme_tintColor = GlobalPicker.switchTintColor
    ////        switchUI.theme_backgroundColor = GlobalPicker.cellBackground
//    }
}
