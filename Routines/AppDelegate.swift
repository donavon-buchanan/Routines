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
// import StoreKit
import SwiftTheme
import SwiftyStoreKit
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    static let afterSyncTimer = AfterSyncTimer()

    static let automaticDarkModeTimer = AutomaticDarkModeTimer()
    static func setAutomaticDarkModeTimer() {
        if Options.getAutomaticDarkModeStatus() {
            automaticDarkModeTimer.startTimer()
        } else {
            automaticDarkModeTimer.stopTimer()
        }
    }

//    let center = UNUserNotificationCenter.current()
    var shortcutItemToProcess: UIApplicationShortcutItem?

    static var syncEngine: SyncEngine?

    static var productInfo: RetrieveResults?

    func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return UIInterfaceOrientationMask.all
        default:
            return UIInterfaceOrientationMask.portrait
        }
    }

    // static let iapObserver = StoreObserver()

//    private func itemCleanup() {
//        let realm = try! Realm()
//        let oldItems = realm.objects(Items.self).filter("isDeleted = \(true)")
//        oldItems.forEach { item in
//            removeDeletedNotifications(id: item.uuidString)
//            item.deleteItem()
//        }
//    }

//    func removeDeletedNotifications(id: String) {
//        // print("Clearing delivered notifications for deleted items")
//        let center = UNUserNotificationCenter.current()
//        center.removeDeliveredNotifications(withIdentifiers: ["\(id)0", "\(id)1", "\(id)2", "\(id)3", id])
//    }
//
//    func removeObsoleteNotifications(id: String) {
//        let center = UNUserNotificationCenter.current()
//        center.removePendingNotificationRequests(withIdentifiers: ["\(id)0", "\(id)1", "\(id)2", "\(id)3", id])
//    }
//
    static func refreshNotifications() {
        printDebug(#function)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // Items.requestNotificationPermission()
        let realm = try! Realm()
        let items = realm.objects(Items.self).filter("isDeleted = %@", false).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
        items.forEach { item in
            item.addNewNotification()
        }
    }

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        printDebug("\(#function) - Start")
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        AppDelegate.registerNotificationCategoriesAndActions()

        migrateRealm()

        AppDelegate.checkOptions()
        AppDelegate.checkRoutinesPlus()

        // Theme
        setUpTheme()
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

        // SwiftyStoreKit
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                    RoutinesPlus.setPurchasedStatus(status: true)
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }

        AppDelegate.setSync()

        observeItems()
        printDebug("\(#function) - End")
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)

        if let subscriptionID = notification?.subscriptionID, IceCreamSubscription.allIDs.contains(subscriptionID) {
            NotificationCenter.default.post(name: Notifications.cloudKitDataDidChangeRemotely.name, object: nil, userInfo: userInfo)
        }
        switch application.applicationState {
        case .active:
            AppDelegate.afterSyncTimer.startTimer()
            completionHandler(.newData)
        case .background:
            backgroundRefresh()
            completionHandler(.newData)
        case .inactive:
            backgroundRefresh()
            completionHandler(.newData)
        @unknown default:
            completionHandler(.newData)
        }

        printDebug("Received push notification")
    }

    func applicationWillResignActive(_: UIApplication) {
        printDebug("\(#function) - Start")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        AppDelegate.afterSyncTimer.stopTimer()
        AppDelegate.automaticDarkModeTimer.stopTimer()

//        AppDelegate.syncEngine?.pushAll()

        printDebug("\(#function) - End")
    }

    func applicationDidEnterBackground(_: UIApplication) {
        printDebug("\(#function) - Start")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AppDelegate.removeOldNotifications()
        AppDelegate.refreshNotifications()

        observeItems()

        printDebug("\(#function) - End")
    }

    static func removeOldNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()

        DispatchQueue.main.async {
            autoreleasepool {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }

    func applicationWillEnterForeground(_: UIApplication) {
        printDebug("\(#function) - Start")
        // AppDelegate.removeOldNotifications()
        // Sync with iCloud
        observeItems()

        printDebug("\(#function) - End")
    }

    func applicationDidBecomeActive(_: UIApplication) {
        printDebug("\(#function) - Start")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // restoreSelectedTab(tab: nil)

        if let shortcutItem = shortcutItemToProcess {
            if shortcutItem.type == "AddAction" {
                goToAdd()
            }
            if shortcutItem.type == "SettingsAction" {
                goToSettings()
            }
            shortcutItemToProcess = nil
        }

        // realmSync()

//        //If presentedVC is nil, that means that Settings or Add were not called, so load the proper tab
//        if self.window?.rootViewController?.presentedViewController == nil {
//            restoreSelectedTab(tab: getCurrentSegmentFromTime())
//        }
        // TableViewController().refreshItems()

        // itemCleanup()
        // updateAppBadgeCount()

        removeOrphanedNotifications()

        AppDelegate.setAutomaticDarkModeTimer()
        printDebug("\(#function) - End")
    }

    func removeOrphanedNotifications() {
        printDebug("\(#function) - Start")
        DispatchQueue.main.async {
            autoreleasepool {
                let center = UNUserNotificationCenter.current()
                var orphanNotifications: [String] = []
                center.getPendingNotificationRequests(completionHandler: { pendingNotifications in
                    pendingNotifications.forEach { notification in
                        let id = notification.identifier
                        let realm = try! Realm()
                        if realm.object(ofType: Items.self, forPrimaryKey: id) == nil {
                            orphanNotifications.append(id)
                        }
                    }
                })
                center.removePendingNotificationRequests(withIdentifiers: orphanNotifications)
            }
        }
        printDebug("\(#function) - End")
    }

    func applicationWillTerminate(_: UIApplication) {
        printDebug("\(#function) - Start")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        // SKPaymentQueue.default().remove(AppDelegate.iapObserver)
        AppDelegate.removeOldNotifications()
        printDebug("\(#function) - End")
    }

//    func application(_: UIApplication, shouldSaveApplicationState _: NSCoder) -> Bool {
//        return true
//    }
//
//    func application(_: UIApplication, shouldRestoreApplicationState _: NSCoder) -> Bool {
//        return true
//    }

    open func restoreSelectedTab(tab: Int?) {
        let rootVC = window?.rootViewController as! TabBarViewController
        if let selectedTab = tab {
            rootVC.selectedIndex = selectedTab
        } else {
            rootVC.selectedIndex = getSelectedTab()
        }
    }

    func getSelectedTab() -> Int {
        var selectedIndex = 0
        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    selectedIndex = options.selectedIndex
                }
            }
        }
        return selectedIndex
    }

//    func setSelectedIndex() {
//        let rootVC = window?.rootViewController as! TabBarViewController
//        let selectedIndex = rootVC.selectedIndex
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                    do {
//                        try realm.write {
//                            options.selectedIndex = selectedIndex
//                        }
//                    } catch {
//                        // print("Error saving selected tab")
//                    }
//                }
//            }
//        }
//    }

    // MARK: - Options Realm

    // var timeArray: [DateComponents?] = []
//    //Options Properties
    // let realm = try! Realm()

    // let realmDispatchQueueLabel: String = "background"

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
//        let configCheck = Realm.Configuration()
//        do {
//            // let fileUrlIs = try schemaVersionAtURL(configCheck.fileURL!)
//            // print("schema version \(fileUrlIs)")
//        } catch {
//            // print(error)
//        }

        // print("performing realm migration")
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 21,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in

                if oldSchemaVersion < 15 {
                    migration.enumerateObjects(ofType: Options.className()) { oldObject, newObject in
                        print("oldObject: " + String(describing: oldObject))
                        print("newObject: " + String(describing: newObject))
                    }
                    // TODO: !!! Items class name can't migrate because class name changed !!!
                    // TODO: Also, future migrations may conflict with iCloud
                    migration.enumerateObjects(ofType: Items.className()) { _, newObject in
                        // print("oldObject: " + String(describing: oldObject))
                        newObject!["isDeleted"] = false
                        newObject!["dateModified"] = Date()
                        newObject!["completeUntil"] = Date()
                        newObject!["repeats"] = true
                        // print("newObject: " + String(describing: newObject))
                    }
                }

                if oldSchemaVersion < 18 {
                    migration.enumerateObjects(ofType: Items.className()) { oldObject, newObject in
                        print("oldObject: " + String(describing: oldObject))
                        print("newObject: " + String(describing: newObject))
                        let originalSegment = oldObject!["segment"] as! Int
                        newObject!["originalSegment"] = originalSegment
                    }
                }

                if oldSchemaVersion < 21 {
                    // migrate the Options split to RoutinesPlus

                    migration.enumerateObjects(ofType: Options.className()) { oldObject, newObject in
                        debugPrint("oldObject: \(String(describing: oldObject))")
                        debugPrint("newObject: \(String(describing: newObject))")

                        let cloudSync = oldObject!["cloudSync"] as! Bool
                        UserDefaults.standard.set(cloudSync, forKey: "cloudSync")

                        let purchasedProduct = oldObject!["purchasedProduct"] as! String

                        let routinesPlusPurchased = oldObject!["routinesPlusPurchased"] as! Bool

                        let newRoutinesPlus = RoutinesPlus()

                        newRoutinesPlus.routinesPlusKey = RoutinesPlus.primaryKey()
                        newRoutinesPlus.purchasedProduct = purchasedProduct
                        newRoutinesPlus.routinesPlusPurchased = routinesPlusPurchased

                        migration.create("RoutinesPlus", value: newRoutinesPlus)
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
        guard let item = realm.object(ofType: Items.self, forPrimaryKey: uuidString) else { return }

        item.completeItem()
    }

    func snoozeItem(uuidString: String) {
        let realm = try! Realm()
        guard let item = realm.object(ofType: Items.self, forPrimaryKey: uuidString) else { return }

        item.snooze()
    }

    static func setSync() {
        printDebug(#function)
        if RoutinesPlus.getPurchasedStatus(), RoutinesPlus.getCloudSync() {
            printDebug("Enabling cloud syncEngine")

            AppDelegate.syncEngine = SyncEngine(objects: [
                SyncObject<Items>(),
                SyncObject<Options>()
            ], databaseScope: .private)
        } else {
            printDebug("Disabling cloud syncEngine")
            AppDelegate.syncEngine = nil
        }
    }

    // MARK: - Update after Notifications

    var itemsToken: NotificationToken?
    var items: Results<Items>?

    func observeItems() {
        // Observe Results Notifications
        guard itemsToken == nil else { return }
        printDebug(#function + "Setting token and observing items")

        let realm = try! Realm()
        items = realm.objects(Items.self)

        itemsToken = items?.observe { change in
            switch change {
            case .initial:
                printDebug("Initial load. Observing items")
            case .update:
                printDebug("Items list updated in \(#function)")
                AppDelegate.refreshAndUpdate()
            case let .error(error):
                printDebug("Error with items observation: \(error)")
            }
        }
    }

    @objc static func refreshAndUpdate() {
        printDebug(#function)
        AppDelegate.refreshNotifications()
        AppDelegate.updateBadgeFromPush()

        AppDelegate.afterSyncTimer.stopTimer()
    }

    @objc func backgroundRefresh() {
        printDebug(#function)
        AppDelegate.refreshNotifications()
        AppDelegate.updateBadgeFromPush()
    }

    deinit {
        printDebug("\(#function) called. Tokens invalidated")
        itemsToken?.invalidate()
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

        var morningCategory: UNNotificationCategory
        if #available(iOS 12.0, *) {
            morningCategory = UNNotificationCategory(identifier: "morning", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: morningPreviewPlaceholder, categorySummaryFormat: morningSummaryFormat, options: [])
        } else if #available(iOS 11.0, *) {
            morningCategory = UNNotificationCategory(identifier: "morning", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: morningPreviewPlaceholder, options: [])
        } else {
            // Fallback on earlier versions
            morningCategory = UNNotificationCategory(identifier: "morning", actions: [snoozeAction, completeAction], intentIdentifiers: [], options: [])
        }

        var afternoonCategory: UNNotificationCategory
        if #available(iOS 12.0, *) {
            afternoonCategory = UNNotificationCategory(identifier: "afternoon", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: afternoonPreviewPlaceholder, categorySummaryFormat: afternoonSummaryFormat, options: [])
        } else if #available(iOS 11.0, *) {
            afternoonCategory = UNNotificationCategory(identifier: "afternoon", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: afternoonPreviewPlaceholder, options: [])
        } else {
            // Fallback on earlier versions
            afternoonCategory = UNNotificationCategory(identifier: "afternoon", actions: [snoozeAction, completeAction], intentIdentifiers: [], options: [])
        }

        var eveningCategory: UNNotificationCategory
        if #available(iOS 12.0, *) {
            eveningCategory = UNNotificationCategory(identifier: "evening", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: eveningPreviewPlaceholder, categorySummaryFormat: eveningSummaryFormat, options: [])
        } else if #available(iOS 11.0, *) {
            eveningCategory = UNNotificationCategory(identifier: "evening", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: eveningPreviewPlaceholder, options: [])
        } else {
            // Fallback on earlier versions
            eveningCategory = UNNotificationCategory(identifier: "evening", actions: [snoozeAction, completeAction], intentIdentifiers: [], options: [])
        }

        var nightCategory: UNNotificationCategory
        if #available(iOS 12.0, *) {
            nightCategory = UNNotificationCategory(identifier: "night", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nightPreviewPlaceholder, categorySummaryFormat: nightSummaryFormat, options: [])
        } else if #available(iOS 11.0, *) {
            nightCategory = UNNotificationCategory(identifier: "night", actions: [snoozeAction, completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nightPreviewPlaceholder, options: [])
        } else {
            // Fallback on earlier versions
            nightCategory = UNNotificationCategory(identifier: "night", actions: [snoozeAction, completeAction], intentIdentifiers: [], options: [])
        }

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

    private static func updateBadgeFromPush() {
        printDebug(#function)
        printDebug("updating badge from remote push")
        let center = UNUserNotificationCenter.current()
        var remoteBadge = 0
        center.getDeliveredNotifications { deliveredNotifications in
            remoteBadge = deliveredNotifications.count
        }
        UIApplication.shared.applicationIconBadgeNumber = remoteBadge
    }

//    func removeAllNotificationsForItem(uuidString: String) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let item = realm.object(ofType: Items.self, forPrimaryKey: uuidString) {
//
//                }
//            }
//        }
//    }

//    func scheduleNewNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
//        // print("running scheduleNewNotification")
//        let notificationCenter = UNUserNotificationCenter.current()
//
//        notificationCenter.getNotificationSettings { settings in
//            // DO not schedule notifications if not authorized
//            guard settings.authorizationStatus == .authorized else {
//                // self.requestNotificationPermission()
//                // print("Authorization status has changed to unauthorized for notifications")
//                return
//            }
//
//            DispatchQueue(label: self.realmDispatchQueueLabel).sync {
//                autoreleasepool {
//                    let realm = try! Realm()
//                    let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
//                    switch segment {
//                    case 1:
//                        if (options?.afternoonNotificationsOn)! {
//                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//                        } else {
//                            // print("Afternoon Notifications toggled off. Aborting")
//                            return
//                        }
//                    case 2:
//                        if (options?.eveningNotificationsOn)! {
//                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//                        } else {
//                            // print("Afternoon Notifications toggled off. Aborting")
//                            return
//                        }
//                    case 3:
//                        if (options?.nightNotificationsOn)! {
//                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//                        } else {
//                            // print("Afternoon Notifications toggled off. Aborting")
//                            return
//                        }
//                    default:
//                        if (options?.morningNotificationsOn)! {
//                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//                        } else {
//                            // print("Afternoon Notifications toggled off. Aborting")
//                            return
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func createBasicNotification(title: String, notes: String?) {
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.sound = UNNotificationSound.default
//
//        if let notesText = notes {
//            content.body = notesText
//        }
//
//        // let trigger = UNNotificationTrigger()
//
//        // Create the request
//        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
//
//        // Schedule the request with the system
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.add(request) { error in
//            if error != nil {
//                // TODO: handle notification errors
//                // print(String(describing: error))
//            } else {
//                // print("Notification created successfully")
//            }
//        }
//    }
//
//    func createNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
//        // print("createNotification running")
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.sound = UNNotificationSound.default
//        content.threadIdentifier = String(getItemSegment(id: uuidString))
//
//        content.badge = NSNumber(integerLiteral: AppDelegate.setBadgeNumber())
//
//        if let notesText = notes {
//            content.body = notesText
//        }
//
//        // Assign the category (and the associated actions).
//        switch segment {
//        case 1:
//            content.categoryIdentifier = "afternoon"
//        case 2:
//            content.categoryIdentifier = "evening"
//        case 3:
//            content.categoryIdentifier = "night"
//        default:
//            content.categoryIdentifier = "morning"
//        }
//
//        var dateComponents = DateComponents()
//        dateComponents.calendar = Calendar.autoupdatingCurrent
//        // Keep notifications from occurring too early for tasks created for tomorrow
//        if firstDate > Date() {
//            // print("Notification set to tomorrow")
//            dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: firstDate)
//        }
//        dateComponents.timeZone = TimeZone.autoupdatingCurrent
//
//        dateComponents.hour = Options.getOptionHour(segment: segment)
//        dateComponents.minute = Options.getOptionMinute(segment: segment)
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//
//        // Create the request
//        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
//
//        // Schedule the request with the system
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.add(request) { error in
//            if error != nil {
//                // TODO: handle notification errors
//                // print(String(describing: error))
//            } else {
//                // print("Notification created successfully")
//            }
//        }
//    }

    // Notification Settings Screen
    fileprivate func goToSettings() {
        // print("Opening settings")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let optionsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsView") as! OptionsTableViewController
        let rootVC = window?.rootViewController as! TabBarViewController
        // Set the selected index so you know what child will be on screen
        let index = getSelectedTab()
        rootVC.selectedIndex = index
        // This is kind of a cheat, but it works
        let navVC = rootVC.children[index] as! NavigationViewController
        navVC.pushViewController(optionsViewController, animated: true)
        TableViewController.setAppearance(segment: index)
    }

    fileprivate func goToAdd() {
        // print("Opening Add view")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addViewController = storyBoard.instantiateViewController(withIdentifier: "addView") as! AddTableViewController
        let rootVC = window?.rootViewController as! TabBarViewController
        // Set the selected index so you know what child will be on screen
        let index = getSelectedTab()
        rootVC.selectedIndex = index
        // This is kind of a cheat, but it works
        let navVC = rootVC.children[index] as! NavigationViewController
        navVC.pushViewController(addViewController, animated: true)
        addViewController.editingSegment = index
        TableViewController.setAppearance(segment: index)
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
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let item = realm.object(ofType: Items.self, forPrimaryKey: identifier) {
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

    func setUpTheme() {
        // tab bar
        let tabBar = UITabBar.appearance()
        tabBar.theme_tintColor = GlobalPicker.barTextColor
        tabBar.theme_barStyle = GlobalPicker.barStyle
        tabBar.theme_barTintColor = GlobalPicker.tabBarTintColor

        // Themes.restoreLastTheme()

        // status bar

        UIApplication.shared.theme_setStatusBarStyle([.default, .default, .default, .lightContent, .lightContent, .lightContent, .lightContent, .lightContent, .lightContent], animated: true)

        // navigation bar

        let navigationBar = UINavigationBar.appearance()

        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)

        let titleAttributes = GlobalPicker.barTextColors.map { hexString in
            [
                NSAttributedString.Key.foregroundColor: UIColor(rgba: hexString),
                // NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),

                NSAttributedString.Key.shadow: shadow
            ]
        }

        window?.theme_backgroundColor = GlobalPicker.backgroundColor
        navigationBar.theme_barStyle = GlobalPicker.barStyle
        navigationBar.theme_tintColor = GlobalPicker.barTextColor
        // navigationBar.theme_barTintColor = GlobalPicker.barTintColor
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)
        navigationBar.theme_largeTitleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)

        // Cells
        let cell = UITableViewCell.appearance()
        cell.theme_backgroundColor = GlobalPicker.barTintColor
        cell.theme_tintColor = GlobalPicker.barTextColor

        // switches
        let switchUI = UISwitch.appearance()
        switchUI.theme_onTintColor = GlobalPicker.switchTintColor
        switchUI.theme_tintColor = GlobalPicker.switchTintColor
        switchUI.theme_backgroundColor = GlobalPicker.cellBackground
    }

//    func getSelectedTab() -> Int {
//        var selectedIndex = 0
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                    selectedIndex = options.selectedIndex
//                }
//            }
//        }
//        return selectedIndex
//    }
}
