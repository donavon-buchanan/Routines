//
//  CustomTimesTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

//TODO: You need to fetch uuidStrings on all current items and modify their associated notifications to match any updated times. Run those updates in async. It could be many.

import UIKit
import RealmSwift
import UserNotifications
import UserNotificationsUI

class CustomTimesTableViewController: UITableViewController {
    
    @IBOutlet weak var morningDatePicker: UIDatePicker!
    @IBOutlet weak var afternoonDatePicker: UIDatePicker!
    @IBOutlet weak var eveningDatePicker: UIDatePicker!
    @IBOutlet weak var nightDatePicker: UIDatePicker!
    
    @IBOutlet var datePickers: [UIDatePicker]!
    
    
    @IBAction func morningTimeSet(_ sender: UIDatePicker) {
        updateSavedTimes(segment: 0, hour: getHour(date: morningDatePicker.date), minute: getMinute(date: morningDatePicker.date))
        print("Picker sent: \(String(describing: sender.date))")
        removeNotificationsForSegment(segment: 0)
        enableNotificationsForSegment(segment: 0)
    }
    @IBAction func afternoonTimeSet(_ sender: UIDatePicker) {
        updateSavedTimes(segment: 1, hour: getHour(date: afternoonDatePicker.date), minute: getMinute(date: afternoonDatePicker.date))
        print("Picker sent: \(String(describing: sender.date))")
        removeNotificationsForSegment(segment: 1)
        enableNotificationsForSegment(segment: 1)
    }
    @IBAction func eveningTimeSet(_ sender: UIDatePicker) {
        updateSavedTimes(segment: 2, hour: getHour(date: eveningDatePicker.date), minute: getMinute(date: eveningDatePicker.date))
        print("Picker sent: \(String(describing: sender.date))")
        removeNotificationsForSegment(segment: 2)
        enableNotificationsForSegment(segment: 2)
    }
    @IBAction func nightTimeSet(_ sender: UIDatePicker) {
        updateSavedTimes(segment: 3, hour: getHour(date: nightDatePicker.date), minute: getMinute(date: nightDatePicker.date))
        print("Picker sent: \(String(describing: sender.date))")
        removeNotificationsForSegment(segment: 3)
        enableNotificationsForSegment(segment: 3)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if getDarkModeStatus() {
            datePickers.forEach { (picker) in
                picker.setValue(UIColor.white, forKeyPath: "textColor")
            }
        } else {
            datePickers.forEach { (picker) in
                picker.setValue(UIColor.black, forKeyPath: "textColor")
            }
        }
        self.tableView.theme_backgroundColor = GlobalPicker.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadOptions()
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //keep saved times updated with what's shown in UI
        saveAllTimes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveAllTimes()
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 4
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var numberOfRows: Int
//        switch section {
//        case 0:
//            numberOfRows = 1
//        case 1:
//            numberOfRows = 1
//        case 2:
//            numberOfRows = 1
//        case 3:
//            numberOfRows = 1
//        default:
//            numberOfRows = 1
//        }
//
//        return numberOfRows
//    }
    
    //Save all times
    func saveAllTimes() {
        let datePickerArray: [UIDatePicker] = [morningDatePicker, afternoonDatePicker, eveningDatePicker, nightDatePicker]
        updateSavedTimes(segment: 0, hour: getHour(date: datePickerArray[0].date), minute: getMinute(date: datePickerArray[0].date))
        updateSavedTimes(segment: 1, hour: getHour(date: datePickerArray[1].date), minute: getMinute(date: datePickerArray[1].date))
        updateSavedTimes(segment: 2, hour: getHour(date: datePickerArray[2].date), minute: getMinute(date: datePickerArray[2].date))
        updateSavedTimes(segment: 3, hour: getHour(date: datePickerArray[3].date), minute: getMinute(date: datePickerArray[3].date))
    }
    
    //Set default min times
//    func setDefaultMinTimes() {
//        let datePickerArray: [UIDatePicker] = [morningDatePicker, afternoonDatePicker, eveningDatePicker, nightDatePicker]
//        let pickerCount = datePickerArray.count
//        for picker in 0..<pickerCount {
//            let midnight = DateFormatter().date(from: "12:00 AM")
//            switch picker {
//            case 0:
//                datePickerArray[0].minimumDate = midnight
//            case 1:
//                let minDate = datePickerArray[0].date.addingTimeInterval(3600)
//                datePickerArray[1].minimumDate = minDate
//            case 2:
//                let minDate = datePickerArray[1].date.addingTimeInterval(3600)
//                datePickerArray[2].minimumDate = minDate
//            case 3:
//                let minDate = datePickerArray[2].date.addingTimeInterval(3600)
//                datePickerArray[3].minimumDate = minDate
//            default:
//                break
//            }
//        }
//        //keep saved times updated with what's shown in UI
//        updateSavedTimes(segment: 0, time: datePickerArray[0].date)
//        updateSavedTimes(segment: 1, time: datePickerArray[1].date)
//        updateSavedTimes(segment: 2, time: datePickerArray[2].date)
//        updateSavedTimes(segment: 3, time: datePickerArray[3].date)
//
//        setDefaultMaxTimes()
//    }
    
//    func setDefaultMaxTimes() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeStyle = .short
//        morningDatePicker.maximumDate = dateFormatter.date(from: "8:45 PM")
//        afternoonDatePicker.maximumDate = dateFormatter.date(from: "9:45 PM")
//        eveningDatePicker.maximumDate = dateFormatter.date(from: "10:45 PM")
//        nightDatePicker.maximumDate = dateFormatter.date(from: "11:45 PM")
//
//    }
//
//    func setMinMaxTimes() {
//        setDefaultMinTimes()
//        //setDefaultMaxTimes()
//    }
    
    //MARK: - Options Realm
    
    func updateSavedTimes(segment: Int, hour: Int, minute: Int) {
        print("updateSavedTimes received: Hour - \(hour), minute - \(minute)")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                do {
                    try realm.write {
                        switch segment {
                        case 1:
                            options?.afternoonHour = hour
                            options?.afternoonMinute = minute
                        case 2:
                            options?.eveningHour = hour
                            options?.eveningMinute = minute
                        case 3:
                            options?.nightHour = hour
                            options?.nightMinute = minute
                        default:
                            options?.morningHour = hour
                            options?.morningMinute = minute
                        }
                    }
                } catch {
                    print("updateSavedTimes failed")
                }
            }
        }
    }
    
    func setUpUI() {
        if let morningTime = getTimesFromOptions(segment: 0) {
            self.morningDatePicker.setDate(morningTime, animated: false)
        }
        if let afternoonTime = getTimesFromOptions(segment: 1) {
            self.afternoonDatePicker.setDate(afternoonTime, animated: false)
        }
        if let eveningTime = getTimesFromOptions(segment: 2) {
            self.eveningDatePicker.setDate(eveningTime, animated: false)
        }
        if let nightTime = getTimesFromOptions(segment: 3) {
            self.nightDatePicker.setDate(nightTime, animated: false)
        }
    }
    
    func getTimesFromOptions(segment: Int) -> Date? {
        var date: Date?
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    //let dateFormatter = DateFormatter()
                    
                    switch segment {
                    case 1:
                        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, hour: options.afternoonHour, minute: options.afternoonMinute)
                        date = dateComponents.date!
                    case 2:
                        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, hour: options.eveningHour, minute: options.eveningMinute)
                        date = dateComponents.date!
                    case 3:
                        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, hour: options.nightHour, minute: options.nightMinute)
                        date = dateComponents.date!
                    default:
                        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, hour: options.morningHour, minute: options.morningMinute)
                        date = dateComponents.date!
                    }
                }
            }
        }
        return date
    }
    
    //MARK: - Adjust Notifications
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
    
    //This is the one to run when setting up a brand new notification
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
        
        content.badge = NSNumber(integerLiteral: AppDelegate().setBadgeNumber(segment: segment))
        
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
    
    public func removeNotification(uuidString: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidString)
    }
    
    func removeNotificationsForSegment(segment: Int) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                let items = realm.objects(Items.self).filter("segment = \(segment)")
//                items.forEach({ (item) in
//                    self.removeNotification(uuidString: [item.uuidString, item.afternoonUUID, item.eveningUUID, item.nightUUID])
//                })
//            }
//        }
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func enableNotificationsForSegment(segment: Int) {
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                let items = realm.objects(Items.self)//.filter("segment = \(segment)")
                items.forEach({ (item) in
                    if self.getAutoSnoozeStatus() {
                        self.scheduleAutoSnoozeNotifications(title: item.title!, notes: item.notes, segment: item.segment, uuidString: item.uuidString, firstDate: item.dateModified!)
                    } else {
                        if self.getSegmentNotificationOption(segment: segment) {
                            self.scheduleNewNotification(title: item.title!, notes: item.notes, segment: item.segment, uuidString: item.uuidString, firstDate: item.dateModified!)
                        }
                    }
                })
            }
        }
    }
    
    func addOrRemoveNotifications(isOn: Bool, segment: Int) {
        if isOn {
            enableNotificationsForSegment(segment: segment)
        } else {
            removeNotificationsForSegment(segment: segment)
        }
    }
    
    
    //MARK: - Conversion functions
    func getTime(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let defaultTimeStrings = ["07:00 AM", "12:00 PM", "5:00 PM", "9:00 PM"]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        if let setTime = timeOption {
            time = setTime
        } else {
            time = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
        }
        
        return time
    }
    
    func getHour(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: date)
        return Int(hour)!
    }
    
    func getMinute(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let minutes = dateFormatter.string(from: date)
        return Int(minutes)!
    }
    
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
    
    //Set the notification badge count
    func getSegmentCount(segment: Int) -> Int {
        var count = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Items.self).filter("segment = \(segment)").count
            }
        }
        return count
    }
    
    //Mark: - Realm
    
    let realmDispatchQueueLabel: String = "background"
    let optionsKey = "optionsKey"
    
    lazy var morningHour: Int = 7
    lazy var morningMinute: Int = 0
    
    lazy var afternoonHour: Int = 12
    lazy var afternoonMinute: Int = 0
    
    lazy var eveningHour: Int = 17
    lazy var eveningMinute: Int = 0
    
    lazy var nightHour: Int = 21
    lazy var nightMinute: Int = 0
    
    //Load Options
    func loadOptions() {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    self.morningHour = options.morningHour
                    self.morningMinute = options.morningMinute
                    
                    self.afternoonHour = options.afternoonHour
                    self.afternoonMinute = options.afternoonMinute
                    
                    self.eveningHour = options.eveningHour
                    self.eveningMinute = options.eveningMinute
                    
                    self.nightHour = options.nightHour
                    self.nightMinute = options.nightMinute
                }
            }
        }
    }
    
    func getSegmentNotification(segment: Int) -> Bool {
        var enabled = false
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
                    switch segment {
                    case 1:
                        enabled = options.afternoonNotificationsOn
                    case 2:
                        enabled = options.eveningNotificationsOn
                    case 3:
                        enabled = options.nightNotificationsOn
                    default:
                        enabled = options.morningNotificationsOn
                    }
                }
            }
        }
        return enabled
    }
    
    //Smart Snooze
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
