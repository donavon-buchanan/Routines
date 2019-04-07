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
import SwiftTheme
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    let center = UNUserNotificationCenter.current()
    var shortcutItemToProcess: UIApplicationShortcutItem?

    var syncEngine: SyncEngine?

    private func itemCleanup() {
        let realm = try! Realm()
        let oldItems = realm.objects(Item.self).filter("isDeleted = \(true)")
        oldItems.forEach { item in
            removeDeletedNotifications(id: item.uuidString)
            item.deleteItem()
        }
    }

    func removeDeletedNotifications(id: String) {
        print("Clearing delivered notifications for deleted items")
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: ["\(id)0", "\(id)1", "\(id)2", "\(id)3", id])
    }

    func refreshNotifications() {
        let realm = try! Realm()
        let oldItems = realm.objects(Item.self).filter("isDeleted = \(true)")
        oldItems.forEach { item in
            removeDeletedNotifications(id: item.uuidString)
        }

        OptionsTableViewController().addOrRemoveNotifications(isOn: OptionsTableViewController().getSegmentNotification(segment: 0), segment: 0)
        OptionsTableViewController().addOrRemoveNotifications(isOn: OptionsTableViewController().getSegmentNotification(segment: 1), segment: 1)
        OptionsTableViewController().addOrRemoveNotifications(isOn: OptionsTableViewController().getSegmentNotification(segment: 2), segment: 2)
        OptionsTableViewController().addOrRemoveNotifications(isOn: OptionsTableViewController().getSegmentNotification(segment: 3), segment: 3)
    }

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        center.delegate = self

        requestNotificationPermission()
        registerNotificationCategoriesAndActions()

        // Theme
        setUpTheme()

        return true
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        migrateRealm()

        // Sync with iCloud
        syncEngine = SyncEngine(objects: [
            SyncObject<Item>(),
            SyncObject<Options>(),
        ])
        UIApplication.shared.registerForRemoteNotifications()

        // checkToCreateOptions()
        loadOptions()
        // setUpTheme()

        // If launchOptions contains the appropriate launch options key, a Home screen quick action
        // is responsible for launching the app. Store the action for processing once the app has
        // completed initialization.
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            shortcutItemToProcess = shortcutItem
        }

        return true
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)

        if notification?.subscriptionID == IceCreamConstant.cloudKitSubscriptionID {
            NotificationCenter.default.post(name: Notifications.cloudKitDataDidChangeRemotely.name, object: nil, userInfo: userInfo)
        }
        completionHandler(.newData)
        itemCleanup()

        TableViewController().refreshItems()
        //try to refresh notifications in the background
        refreshNotifications()
        /* TODO: Add option in Settings.app to clear all existing iCloud data in case a total reset is needed. */
        updateAppBadgeCount()
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        updateAppBadgeCount()
        // saveSelectedTab()
        itemCleanup()
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        updateAppBadgeCount()
        itemCleanup()
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        TableViewController().refreshItems()
        itemCleanup()
        updateAppBadgeCount()
    }

    func applicationDidBecomeActive(_: UIApplication) {
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

//        //If presentedVC is nil, that means that Settings or Add were not called, so load the proper tab
//        if self.window?.rootViewController?.presentedViewController == nil {
//            restoreSelectedTab(tab: getCurrentSegmentFromTime())
//        }
        TableViewController().refreshItems()
        itemCleanup()
        updateAppBadgeCount()
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Themes.saveLastTheme()
        updateAppBadgeCount()
        itemCleanup()
    }

//    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
//        return true
//    }
//
//    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
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
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    selectedIndex = options.selectedIndex
                }
            }
        }
        return selectedIndex
    }

    func saveSelectedTab() {
        let rootVC = window?.rootViewController as! TabBarViewController
        let selectedIndex = rootVC.selectedIndex
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    do {
                        try realm.write {
                            options.selectedIndex = selectedIndex
                        }
                    } catch {
                        print("Error saving selected tab")
                    }
                }
            }
        }
    }

    // MARK: - Options Realm

    var timeArray: [DateComponents?] = []
//    //Options Properties
    // let realm = try! Realm()
    var optionsObject: Options?
    let optionsKey = "optionsKey"
    let realmDispatchQueueLabel: String = "background"

    func migrateRealm() {
        let configCheck = Realm.Configuration()
        do {
            let fileUrlIs = try schemaVersionAtURL(configCheck.fileURL!)
            print("schema version \(fileUrlIs)")
        } catch {
            print(error)
        }

        print("performing realm migration")
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 13,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { _, oldSchemaVersion in
                print("oldSchemaVersion: \(oldSchemaVersion)")
                if oldSchemaVersion < 2 {
                    print("Migration block running")
                    DispatchQueue(label: self.realmDispatchQueueLabel).async {
                        autoreleasepool {
                            let realm = try! Realm()
                            let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)

                            do {
                                try realm.write {
                                    if let morningTime = options?.morningStartTime {
                                        options?.morningHour = self.getHour(date: morningTime)
                                        options?.morningMinute = self.getMinute(date: morningTime)
                                    }
                                    if let afternoonTime = options?.afternoonStartTime {
                                        options?.afternoonHour = self.getHour(date: afternoonTime)
                                        options?.afternoonMinute = self.getMinute(date: afternoonTime)
                                    }
                                    if let eveningTime = options?.eveningStartTime {
                                        options?.eveningHour = self.getHour(date: eveningTime)
                                        options?.eveningMinute = self.getMinute(date: eveningTime)
                                    }
                                    if let nightTime = options?.nightStartTime {
                                        options?.nightHour = self.getHour(date: nightTime)
                                        options?.nightMinute = self.getMinute(date: nightTime)
                                    }
                                }
                            } catch {
                                print("Error with migration")
                            }
                        }
                    }
                }

//                if oldSchemaVersion < 13 {
//                    // The enumerateObjects(ofType:_:) method iterates
//                    // over every Person object stored in the Realm file
//                    migration.enumerateObjects(ofType: Item.className()) { _, newObject in
//                        // combine name fields into a single field
//                        newObject!["isDeleted"] = false }
//                }

                if oldSchemaVersion < 13 {}
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
    }

//    func getHour(date: Date) -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH"
//        let hour = dateFormatter.string(from: date)
//        return Int(hour)!
//    }
//
//    func getMinute(date: Date) -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "mm"
//        let minutes = dateFormatter.string(from: date)
//        return Int(minutes)!
//    }

    func getOptionHour(segment: Int) -> Int {
        var hour = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    hour = (options?.afternoonHour)!
                case 2:
                    hour = (options?.eveningHour)!
                case 3:
                    hour = (options?.nightHour)!
                default:
                    hour = (options?.morningHour)!
                }
            }
        }
        return hour
    }

    func getOptionMinute(segment: Int) -> Int {
        var minute = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    minute = (options?.afternoonMinute)!
                case 2:
                    minute = (options?.eveningMinute)!
                case 3:
                    minute = (options?.nightMinute)!
                default:
                    minute = (options?.morningMinute)!
                }
            }
        }
        return minute
    }

    // Load Options
    func loadOptions() {
        let realm = try! Realm()
        optionsObject = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)

        if let currentOptions = realm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
            optionsObject = currentOptions
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

    func completeItem(uuidString: String) {
        // Remove added digit if necessary to get actual uuidString key
        var id: String {
            if uuidString.count > 36 {
                return String(uuidString.dropLast())
            } else {
                return uuidString
            }
        }

        let realm = try! Realm()
        guard let item = realm.object(ofType: Item.self, forPrimaryKey: id) else { return }

        item.syncDelete()

        // Decrement badge if there is one
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        if currentBadgeCount > 0 {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }

        AppDelegate().refreshNotifications()
        updateAppBadgeCount()
    }

    func snoozeItem(uuidString: String) {
        // Remove added digit if necessary to get actual uuidString key
        var id: String {
            if uuidString.count > 36 {
                return String(uuidString.dropLast())
            } else {
                return uuidString
            }
        }

        let realm = try! Realm()
        guard let item = realm.object(ofType: Item.self, forPrimaryKey: id) else { return }

        item.snooze()

        // Decrement badge if there is one
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        if currentBadgeCount > 0 {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
        AppDelegate().refreshNotifications()
        updateAppBadgeCount()
    }

    // MARK: - Manage Notifications

    func requestNotificationPermission() {
        // let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds
        if #available(iOS 12.0, *) {
            center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { granted, _ in
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
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
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

    // Notification Categories and Actions

    func registerNotificationCategoriesAndActions() {
        // let center = UNUserNotificationCenter.current()

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
        print("running userNotificationCenter:didReceive:withCompletionHandler")
        if response.notification.request.content.categoryIdentifier == "morning" {
            print("running response: morning")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                restoreSelectedTab(tab: getNotificationSegment(id: response.notification.request.identifier))
            }
        }

        if response.notification.request.content.categoryIdentifier == "afternoon" {
            print("running response: afternoon")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                restoreSelectedTab(tab: getNotificationSegment(id: response.notification.request.identifier))
            }
        }

        if response.notification.request.content.categoryIdentifier == "evening" {
            print("running response: evening")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                restoreSelectedTab(tab: getNotificationSegment(id: response.notification.request.identifier))
            }
        }

        if response.notification.request.content.categoryIdentifier == "night" {
            print("running response: night")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                restoreSelectedTab(tab: getNotificationSegment(id: response.notification.request.identifier))
            }
        }

        completionHandler()
    }

    func scheduleAutoSnoozeNotifications(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
        // This is where you need to test if a segment is > current segment
        let dayOfFirstDate = Calendar.autoupdatingCurrent.dateComponents([.day], from: firstDate)
        print("dayOfFirstDate: \(dayOfFirstDate)")
        let today = Calendar.autoupdatingCurrent.dateComponents([.day], from: Date())
        print("today: \(today)")
        if segment > 0, dayOfFirstDate == today {
            if getSegmentNotificationOption(segment: 0) {
                scheduleNewNotification(title: title, notes: notes, segment: 0, uuidString: "\(uuidString)0", firstDate: firstDate.startOfNextDay)
                print("morning uuid: " + "\(uuidString)0")
            }
        } else {
            if getSegmentNotificationOption(segment: 0) {
                scheduleNewNotification(title: title, notes: notes, segment: 0, uuidString: "\(uuidString)0", firstDate: firstDate)
                print("morning uuid: " + "\(uuidString)0")
            }
        }
        if segment > 1, dayOfFirstDate == today {
            if getSegmentNotificationOption(segment: 1) {
                scheduleNewNotification(title: title, notes: notes, segment: 1, uuidString: "\(uuidString)1", firstDate: firstDate.startOfNextDay)
                print("afternoon uuid: " + "\(uuidString)1")
            }
        } else {
            if getSegmentNotificationOption(segment: 1) {
                scheduleNewNotification(title: title, notes: notes, segment: 1, uuidString: "\(uuidString)1", firstDate: firstDate)
                print("afternoon uuid: " + "\(uuidString)1")
            }
        }
        if segment > 2, dayOfFirstDate == today {
            if getSegmentNotificationOption(segment: 2) {
                scheduleNewNotification(title: title, notes: notes, segment: 2, uuidString: "\(uuidString)2", firstDate: firstDate.startOfNextDay)
                print("evening uuid: " + "\(uuidString)2")
            }
        } else {
            if getSegmentNotificationOption(segment: 2) {
                scheduleNewNotification(title: title, notes: notes, segment: 2, uuidString: "\(uuidString)2", firstDate: firstDate)
                print("evening uuid: " + "\(uuidString)2")
            }
        }
        if getSegmentNotificationOption(segment: 3) {
            scheduleNewNotification(title: title, notes: notes, segment: 3, uuidString: "\(uuidString)3", firstDate: firstDate)
            print("night uuid: " + "\(uuidString)3")
        }
    }

    func getSegmentNotificationOption(segment: Int) -> Bool {
        var isOn = true
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    if let on = options?.afternoonNotificationsOn {
                        isOn = on
                    }
                case 2:
                    if let on = options?.eveningNotificationsOn {
                        isOn = on
                    }
                case 3:
                    if let on = options?.nightNotificationsOn {
                        isOn = on
                    }
                default:
                    if let on = options?.morningNotificationsOn {
                        isOn = on
                    }
                }
            }
        }
        return isOn
    }

//    func removeAllNotificationsForItem(uuidString: String) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let item = realm.object(ofType: Item.self, forPrimaryKey: uuidString) {
//
//                }
//            }
//        }
//    }

    func removeNotification(uuidString: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidString)
    }

    func scheduleNewNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
        print("running scheduleNewNotification")
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getNotificationSettings { settings in
            // DO not schedule notifications if not authorized
            guard settings.authorizationStatus == .authorized else {
                // self.requestNotificationPermission()
                print("Authorization status has changed to unauthorized for notifications")
                return
            }

            DispatchQueue(label: self.realmDispatchQueueLabel).sync {
                autoreleasepool {
                    let realm = try! Realm()
                    let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                    switch segment {
                    case 1:
                        if (options?.afternoonNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    case 2:
                        if (options?.eveningNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    case 3:
                        if (options?.nightNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    default:
                        if (options?.morningNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    }
                }
            }
        }
    }

    func createNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
        print("createNotification running")
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.threadIdentifier = String(getItemSegment(id: uuidString))

        content.badge = NSNumber(integerLiteral: setBadgeNumber())

        if let notesText = notes {
            content.body = notesText
        }

        // Assign the category (and the associated actions).
        switch segment {
        case 1:
            content.categoryIdentifier = "afternoon"
        case 2:
            content.categoryIdentifier = "evening"
        case 3:
            content.categoryIdentifier = "night"
        default:
            content.categoryIdentifier = "morning"
        }

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        // Keep notifications from occurring too early for tasks created for tomorrow
        if firstDate > Date() {
            print("Notification set to tomorrow")
            dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: firstDate)
        }
        dateComponents.timeZone = TimeZone.autoupdatingCurrent

        dateComponents.hour = getOptionHour(segment: segment)
        dateComponents.minute = getOptionMinute(segment: segment)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the request
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        // Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if error != nil {
                // TODO: handle notification errors
                print(String(describing: error))
            } else {
                print("Notification created successfully")
            }
        }
    }

    // Notification Settings Screen
    fileprivate func goToSettings() {
        print("Opening settings")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let optionsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsView") as! OptionsTableViewController
        let rootVC = window?.rootViewController as! TabBarViewController
        // Set the selected index so you know what child will be on screen
        let index = getSelectedTab()
        rootVC.selectedIndex = index
        // This is kind of a cheat, but it works
        let navVC = rootVC.children[index] as! NavigationViewController
        navVC.pushViewController(optionsViewController, animated: true)
        TableViewController().setAppearance(segment: index)
    }

    fileprivate func goToAdd() {
        print("Opening Add view")
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
        TableViewController().setAppearance(segment: index)
    }

    func userNotificationCenter(_: UNUserNotificationCenter, openSettingsFor _: UNNotification?) {
        goToSettings()
    }

    func application(_: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler _: @escaping (Bool) -> Void) {
        // Alternatively, a shortcut item may be passed in through this delegate method if the app was
        // still in memory when the Home screen quick action was used. Again, store it for processing.
        shortcutItemToProcess = shortcutItem
    }

    func getBadgeOption() -> Bool {
        var badge = true
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    badge = options.badge
                }
            }
        }
        return badge
    }

    open func setBadgeNumber() -> Int {
        var badgeCount = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                // Get all the items in or under the current segment.
                let items = realm.objects(Item.self) // .filter("segment <= %@", segment)
                // Get what should the the furthest future trigger date
                if let lastFutureDate = items.last?.dateModified {
                    badgeCount = items.filter("dateModified <= %@ AND isDeleted = \(false)", lastFutureDate).count
                }
            }
        }
        print("setBadgeNumber found \(badgeCount) items")
        return badgeCount
    }

//    //Doesn't work. Create notification seems to just time out
//    open func setBadgeNumber() -> Int {
//        var badge = 0
//        let semaphore = DispatchSemaphore(value: 0)
//        let center = UNUserNotificationCenter.current()
//        center.getPendingNotificationRequests { (requests) in
//            badge = requests.count
//            semaphore.signal()
//        }
//        semaphore.wait()
//        print("Setting notification badge to: \(badge)")
//        return badge
//    }

    open func updateAppBadgeCount() {
        if getBadgeOption() {
            print("updating app badge number")
            DispatchQueue(label: realmDispatchQueueLabel).sync {
                autoreleasepool {
                    let realm = try! Realm()
                    let badgeCount = realm.objects(Item.self).filter("dateModified < %@ AND isDeleted = \(false)", Date()).count
                    DispatchQueue.main.async {
                        autoreleasepool {
                            UIApplication.shared.applicationIconBadgeNumber = badgeCount
                        }
                    }
                }
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    func getAutoSnoozeStatus() -> Bool {
        var snooze = false
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
                    snooze = options.smartSnooze
                }
            }
        }
        return snooze
    }

    // MARK: - Conversion functions

    func getTime(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let defaultTimeStrings = ["07:00", "12:00", "17:00", "21:00 PM"]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short

        if let setTime = timeOption {
            time = setTime
        } else {
            time = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
        }

        return time
    }

    func getHour(date: Date?) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: date!)
        return Int(hour)!
    }

    func getMinute(date: Date?) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let minutes = dateFormatter.string(from: date!)
        return Int(minutes)!
    }

    func getCurrentSegmentFromTime() -> Int {
        let afternoon = Calendar.autoupdatingCurrent.date(bySettingHour: getOptionHour(segment: 1), minute: getOptionMinute(segment: 1), second: 0, of: Date())
        let evening = Calendar.autoupdatingCurrent.date(bySettingHour: getOptionHour(segment: 2), minute: getOptionMinute(segment: 2), second: 0, of: Date())
        let night = Calendar.autoupdatingCurrent.date(bySettingHour: getOptionHour(segment: 3), minute: getOptionMinute(segment: 3), second: 0, of: Date())

        var currentSegment = 0

        switch Date() {
        case _ where Date() < afternoon!:
            currentSegment = 0
        case _ where Date() < evening!:
            currentSegment = 1
        case _ where Date() < night!:
            currentSegment = 2
        case _ where Date() > night!:
            currentSegment = 3
        default:
            currentSegment = 0
        }
        return currentSegment
    }

    open func getItemSegment(id: String) -> Int {
        var identifier: String {
            if id.count > 36 {
                return String(id.dropLast())
            } else {
                return id
            }
        }
        var segment = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let item = realm.object(ofType: Item.self, forPrimaryKey: identifier) {
                    segment = item.segment
                }
            }
        }
        return segment
    }

    open func getNotificationSegment(id: String) -> Int {
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

                NSAttributedString.Key.shadow: shadow,
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
        cell.theme_backgroundColor = GlobalPicker.cellBackground
        cell.theme_tintColor = GlobalPicker.barTextColor

        // switches
        let switchUI = UISwitch.appearance()
        switchUI.theme_onTintColor = GlobalPicker.switchTintColor
        switchUI.theme_tintColor = GlobalPicker.switchTintColor
        switchUI.theme_backgroundColor = GlobalPicker.cellBackground
    }

    func getDarkModeStatus() -> Bool {
        var darkMode = false
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    darkMode = options.darkMode
                }
            }
        }
        return darkMode
    }
}
