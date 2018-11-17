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
import SwiftTheme

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        center.delegate = self
        
        requestNotificationPermission()
        registerNotificationCategoriesAndActions()
        
        //Theme
        
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        migrateRealm()
        
        //checkToCreateOptions()
        loadOptions()
        setUpTheme()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        updateAppBadgeCount()
        //saveSelectedTab()
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
        restoreSelectedTab()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //Themes.saveLastTheme()
    }
    
    func restoreSelectedTab() {
        let rootVC = self.window?.rootViewController as! TabBarViewController
        var selectedIndex = 0
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    selectedIndex = options.selectedIndex
                }
            }
        }
        rootVC.selectedIndex = selectedIndex
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
        let rootVC = self.window?.rootViewController as! TabBarViewController
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
    
//    //MARK: - Options Realm
    var timeArray: [DateComponents?] = []
//    //Options Properties
    //let realm = try! Realm()
    var optionsObject: Options?
    let optionsKey = "optionsKey"
    let realmDispatchQueueLabel: String = "background"
    
    func migrateRealm() {
        
        let configCheck = Realm.Configuration();
        do {
            let fileUrlIs = try schemaVersionAtURL(configCheck.fileURL!)
            print("schema version \(fileUrlIs)")
        } catch  {
            print(error)
        }
        
        print("performing realm migration")
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 8,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                print("oldSchemaVersion: \(oldSchemaVersion)")
                if (oldSchemaVersion < 2) {
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
                
                if (oldSchemaVersion < 8) {
                    
                }
                
        })
        
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

    //Load Options
    func loadOptions() {
        let realm = try! Realm()
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
    
    func completeItem(uuidString: String) {
        //Remove added digit if necessary to get actual uuidString key
        var id : String {
            if uuidString.count > 36 {
                return String(uuidString.dropLast())
            } else {
                return uuidString
            }
        }
        print("running completeItem")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                print("Completing item with key: \(id)")
                if let item = realm.object(ofType: Items.self, forPrimaryKey: id) {
                    print("Completing item")
                    print(item)
                    do {
                        try realm.write {
                            realm.delete(item)
                        }
                    } catch {
                        print("failed to remove item with Complete action")
                    }
                }
            }
            print("completeItem completed")
        }
        //Add suffix back to uuidString
        self.removeNotification(uuidString: ["\(id)0", "\(id)1", "\(id)2", "\(id)3", id])
        
        //Decrement badge if there is one
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        if currentBadgeCount > 0 {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
        
        OptionsTableViewController().refreshNotifications()
        self.updateAppBadgeCount()
    }
    
    func snoozeItem(uuidString: String) {
        //Remove added digit if necessary to get actual uuidString key
        var id : String {
            if uuidString.count > 36 {
                return String(uuidString.dropLast())
            } else {
                return uuidString
            }
        }
        print("running snoozeItem")
        var title : String?
        var notes : String?
        var itemSegment = Int()
        var itemuuidString = String()
        var dateModified: Date?
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let item = realm.object(ofType: Items.self, forPrimaryKey: id) {
                    //TODO: Could cause out of bounds error? Or actually, it's not an array. The item may just become invisible.
                    let segment = item.segment
                    var newSegment = Int()
                    
                    switch segment {
                    case 3:
                        newSegment = 0
                        itemSegment = 0
                        //Auto snooze will rip it back into Night if we don't set it to next day
                        dateModified = item.dateModified?.startOfNextDay
                    default:
                        newSegment = segment+1
                        itemSegment = segment+1
                        dateModified = item.dateModified
                    }
                    
                    do {
                        try! realm.write {
                            item.segment = newSegment
                            //Make sure to save the new date in case it was changed
                            item.dateModified = dateModified
                        }
                    }
                    title = item.title
                    notes = item.notes
                    itemuuidString = item.uuidString
                    print("snoozeItem Completed")
                    
                }
            }
        }
        if let newTitle = title {
            //TODO: Might need to come back to this for Smart Snooze. For now, leave it alone
            if getAutoSnoozeStatus() {
                scheduleAutoSnoozeNotifications(title: newTitle, notes: notes, segment: itemSegment, uuidString: itemuuidString, firstDate: dateModified!)
            } else {
                scheduleNewNotification(title: newTitle, notes: notes, segment: itemSegment, uuidString: itemuuidString, firstDate: dateModified!)
            }
        }
        //Decrement badge if there is one
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        if currentBadgeCount > 0 {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
        OptionsTableViewController().refreshNotifications()
        self.updateAppBadgeCount()
    }
    
    //MARK: - Manage Notifications
    
    func requestNotificationPermission() {
        //let center = UNUserNotificationCenter.current()
        //Request permission to display alerts and play sounds
        if #available(iOS 12.0, *) {
            center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { (granted, error) in
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
    
    //Notification Categories and Actions
    
    func registerNotificationCategoriesAndActions() {
        //let center = UNUserNotificationCenter.current()
        
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
        
        var morningCategory : UNNotificationCategory
        if #available(iOS 12.0, *) {
            morningCategory = UNNotificationCategory(identifier: "morning", actions: [snoozeAction,completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: morningPreviewPlaceholder, categorySummaryFormat: morningSummaryFormat, options: [])
        } else if #available(iOS 11.0, *) {
            morningCategory = UNNotificationCategory(identifier: "morning", actions: [snoozeAction,completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: morningPreviewPlaceholder, options: [])
        } else {
            // Fallback on earlier versions
            morningCategory = UNNotificationCategory(identifier: "morning", actions: [snoozeAction,completeAction], intentIdentifiers: [], options: [])
        }
        
        var afternoonCategory : UNNotificationCategory
        if #available(iOS 12.0, *) {
            afternoonCategory = UNNotificationCategory(identifier: "afternoon", actions: [snoozeAction,completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: afternoonPreviewPlaceholder, categorySummaryFormat: afternoonSummaryFormat, options: [])
        } else if #available(iOS 11.0, *) {
            afternoonCategory = UNNotificationCategory(identifier: "afternoon", actions: [snoozeAction,completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: afternoonPreviewPlaceholder, options: [])
        } else {
            // Fallback on earlier versions
            afternoonCategory = UNNotificationCategory(identifier: "afternoon", actions: [snoozeAction,completeAction], intentIdentifiers: [], options: [])
        }
        
        var eveningCategory : UNNotificationCategory
        if #available(iOS 12.0, *) {
            eveningCategory = UNNotificationCategory(identifier: "evening", actions: [snoozeAction,completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: eveningPreviewPlaceholder, categorySummaryFormat: eveningSummaryFormat, options: [])
        } else if #available(iOS 11.0, *) {
            eveningCategory = UNNotificationCategory(identifier: "evening", actions: [snoozeAction,completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: eveningPreviewPlaceholder, options: [])
        } else {
            // Fallback on earlier versions
            eveningCategory = UNNotificationCategory(identifier: "evening", actions: [snoozeAction,completeAction], intentIdentifiers: [], options: [])
        }
        
        var nightCategory : UNNotificationCategory
        if #available(iOS 12.0, *) {
            nightCategory = UNNotificationCategory(identifier: "night", actions: [snoozeAction,completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nightPreviewPlaceholder, categorySummaryFormat: nightSummaryFormat, options: [])
        } else if #available(iOS 11.0, *) {
            nightCategory = UNNotificationCategory(identifier: "night", actions: [snoozeAction,completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nightPreviewPlaceholder, options: [])
        } else {
            // Fallback on earlier versions
            nightCategory = UNNotificationCategory(identifier: "night", actions: [snoozeAction,completeAction], intentIdentifiers: [], options: [])
        }
        
        center.setNotificationCategories([morningCategory,afternoonCategory,eveningCategory,nightCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("running userNotificationCenter:didReceive:withCompletionHandler")
        if response.notification.request.content.categoryIdentifier == "morning" {
            print("running response: morning")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                break
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
                break
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
                break
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
                break
            }
        }
        
        
        
        completionHandler()
        
    }
    
    func scheduleAutoSnoozeNotifications(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
        //This is where you need to test if a segment is > current segment
        let dayOfFirstDate = Calendar.autoupdatingCurrent.dateComponents([.day], from: firstDate)
        print("dayOfFirstDate: \(dayOfFirstDate)")
        let today = Calendar.autoupdatingCurrent.dateComponents([.day], from: Date())
        print("today: \(today)")
        if segment > 0 && dayOfFirstDate == today{
            if getSegmentNotificationOption(segment: 0) {
                scheduleNewNotification(title: title, notes: notes, segment: 0, uuidString: "\(uuidString)0", firstDate: firstDate.startOfNextDay)
                print("morning uuid: "+"\(uuidString)0")
            }
        } else {
            if getSegmentNotificationOption(segment: 0) {
                scheduleNewNotification(title: title, notes: notes, segment: 0, uuidString: "\(uuidString)0", firstDate: firstDate)
                print("morning uuid: "+"\(uuidString)0")
            }
        }
        if segment > 1 && dayOfFirstDate == today{
            if getSegmentNotificationOption(segment: 1) {
                scheduleNewNotification(title: title, notes: notes, segment: 1, uuidString: "\(uuidString)1", firstDate: firstDate.startOfNextDay)
                print("afternoon uuid: "+"\(uuidString)1")
            }
        } else {
            if getSegmentNotificationOption(segment: 1) {
                scheduleNewNotification(title: title, notes: notes, segment: 1, uuidString: "\(uuidString)1", firstDate: firstDate)
                print("afternoon uuid: "+"\(uuidString)1")
            }
        }
        if segment > 2 && dayOfFirstDate == today {
            if getSegmentNotificationOption(segment: 2) {
                scheduleNewNotification(title: title, notes: notes, segment: 2, uuidString: "\(uuidString)2", firstDate: firstDate.startOfNextDay)
                print("evening uuid: "+"\(uuidString)2")
            }
        } else {
            if getSegmentNotificationOption(segment: 2) {
                scheduleNewNotification(title: title, notes: notes, segment: 2, uuidString: "\(uuidString)2", firstDate: firstDate)
                print("evening uuid: "+"\(uuidString)2")
            }
        }
        if getSegmentNotificationOption(segment: 3) {
            scheduleNewNotification(title: title, notes: notes, segment: 3, uuidString: "\(uuidString)3", firstDate: firstDate)
            print("night uuid: "+"\(uuidString)3")
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
//                if let item = realm.object(ofType: Items.self, forPrimaryKey: uuidString) {
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
        
        notificationCenter.getNotificationSettings { (settings) in
            //DO not schedule notifications if not authorized
            guard settings.authorizationStatus == .authorized else {
                //self.requestNotificationPermission()
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
        content.threadIdentifier = String(segment)
        
        content.badge = NSNumber(integerLiteral: setBadgeNumber(segment: segment))
        
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
        //Keep notifications from occurring too early for tasks created for tomorrow
        if firstDate > Date() {
            print("Notification set to tomorrow")
            dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: firstDate)
        }
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        
        dateComponents.hour = getOptionHour(segment: segment)
        dateComponents.minute = getOptionMinute(segment: segment)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //Create the request
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        //Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                //TODO: handle notification errors
                print(String(describing: error))
            } else {
                print("Notification created successfully")
            }
        }
        
    }
    
    //Notification Settings Screen
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("Opening settings")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let optionsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsView") as! OptionsTableViewController
        let rootVC = self.window?.rootViewController as! TabBarViewController
        //Set the selected index so you know what child will be on screen
        let index = getSelectedTab()
        rootVC.selectedIndex = index
        //This is kind of a cheat, but it works
        let navVC = rootVC.children[index] as! NavigationViewController
        navVC.pushViewController(optionsViewController, animated: false)
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
    
    func updateAppBadgeCount() {
        
    }
    
    open func setBadgeNumber(segment: Int) -> Int {
        var badgeCount = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                //Get all the items in or under the current segment.
                let items = realm.objects(Items.self).filter("segment <= %@", segment)
                //Get what should the the furthest future trigger date
                if let lastFutureDate = items.last?.dateModified {
                    badgeCount = items.filter("dateModified <= %@", lastFutureDate).count
                }
            }
        }
        return badgeCount
    }
//    func updateAppBadgeCount() {
//        if getBadgeOption() {
//            print("updating app badge number")
//            DispatchQueue(label: realmDispatchQueueLabel).async {
//                autoreleasepool {
//                    let realm = try! Realm()
//                    let badgeCount = realm.objects(Items.self).filter("dateModified < %@",Date()).count
//                    DispatchQueue.main.async {
//                        autoreleasepool {
//                            UIApplication.shared.applicationIconBadgeNumber = badgeCount
//                        }
//                    }
//                }
//            }
//        } else {
//            UIApplication.shared.applicationIconBadgeNumber = 0
//        }
//    }
    
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
    
    //MARK: - Conversion functions
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
    
    //MARK: - Themes
    func setUpTheme() {
        
        //Themes.restoreLastTheme()
        
        // status bar
        
        UIApplication.shared.theme_setStatusBarStyle([.default, .default, .default, .lightContent, .lightContent, .lightContent, .lightContent, .lightContent, .lightContent], animated: true)
        
        // navigation bar
        
        let navigationBar = UINavigationBar.appearance()
        
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        let titleAttributes = GlobalPicker.barTextColors.map { hexString in
            return [
                NSAttributedString.Key.foregroundColor: UIColor(rgba: hexString),
                //NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                
                NSAttributedString.Key.shadow: shadow
            ]
        }
        
        self.window?.theme_backgroundColor = GlobalPicker.backgroundColor
        navigationBar.theme_barStyle = GlobalPicker.barStyle
        navigationBar.theme_tintColor = GlobalPicker.barTextColor
        //navigationBar.theme_barTintColor = GlobalPicker.barTintColor
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)
        navigationBar.theme_largeTitleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)
        
        // tab bar
        let tabBar = UITabBar.appearance()
        
        tabBar.theme_tintColor = GlobalPicker.barTextColor
        tabBar.theme_barStyle = GlobalPicker.barStyle
        tabBar.theme_barTintColor = GlobalPicker.tabBarTintColor
        
        //Cells
        let cell = UITableViewCell.appearance()
        cell.theme_backgroundColor = GlobalPicker.cellBackground
        cell.theme_tintColor = GlobalPicker.barTextColor
        
        //switches
        let switchUI = UISwitch.appearance()
        switchUI.theme_onTintColor = GlobalPicker.barTextColor
        switchUI.theme_tintColor = GlobalPicker.barTextColor
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

