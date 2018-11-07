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
    
    @IBAction func morningTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes(segment: 0, time: sender.date)
        print("Picker sent: \(String(describing: sender.date))")
        removeNotificationsForSegment(segment: 0)
        enableNotificationsForSegment(segment: 0)
    }
    @IBAction func afternoonTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes(segment: 1, time: sender.date)
        print("Picker sent: \(String(describing: sender.date))")
        removeNotificationsForSegment(segment: 1)
        enableNotificationsForSegment(segment: 1)
    }
    @IBAction func eveningTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes(segment: 2, time: sender.date)
        print("Picker sent: \(String(describing: sender.date))")
        removeNotificationsForSegment(segment: 2)
        enableNotificationsForSegment(segment: 2)
    }
    @IBAction func nightTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes(segment: 3, time: sender.date)
        print("Picker sent: \(String(describing: sender.date))")
        removeNotificationsForSegment(segment: 3)
        enableNotificationsForSegment(segment: 3)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.tableFooterView = UIView()
        setDefaultMaxTimes()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadOptions()
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setMinMaxTimes()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 1
        case 2:
            numberOfRows = 1
        case 3:
            numberOfRows = 1
        default:
            numberOfRows = 1
        }
        
        return numberOfRows
    }
    
    //Set default min times
    func setDefaultMinTimes() {
        let datePickerArray: [UIDatePicker] = [morningDatePicker, afternoonDatePicker, eveningDatePicker, nightDatePicker]
        let pickerCount = datePickerArray.count
        for picker in 0..<pickerCount {
            let midnight = DateFormatter().date(from: "12:00 AM")
            switch picker {
            case 0:
                datePickerArray[0].minimumDate = midnight
            case 1:
                let minDate = datePickerArray[0].date.addingTimeInterval(3600)
                datePickerArray[1].minimumDate = minDate
            case 2:
                let minDate = datePickerArray[1].date.addingTimeInterval(3600)
                datePickerArray[2].minimumDate = minDate
            case 3:
                let minDate = datePickerArray[2].date.addingTimeInterval(3600)
                datePickerArray[3].minimumDate = minDate
            default:
                break
            }
        }
        //keep saved times updated with what's shown in UI
        updateSavedTimes(segment: 0, time: datePickerArray[0].date)
        updateSavedTimes(segment: 1, time: datePickerArray[1].date)
        updateSavedTimes(segment: 2, time: datePickerArray[2].date)
        updateSavedTimes(segment: 3, time: datePickerArray[3].date)
    }
    
    func setDefaultMaxTimes() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        morningDatePicker.maximumDate = dateFormatter.date(from: "8:45 PM")
        afternoonDatePicker.maximumDate = dateFormatter.date(from: "9:45 PM")
        eveningDatePicker.maximumDate = dateFormatter.date(from: "10:45 PM")
        nightDatePicker.maximumDate = dateFormatter.date(from: "11:45 PM")

    }
    
    func setMinMaxTimes() {
        setDefaultMinTimes()
        //setDefaultMaxTimes()
    }
    
    //MARK: - Options Realm
    
    func updateSavedTimes(segment: Int, time: Date) {
        print("updateSavedTimes received: \(String(describing: time))")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                do {
                    try realm.write {
                        switch segment {
                        case 1:
                            options?.self.afternoonStartTime = time
                        case 2:
                            options?.self.eveningStartTime = time
                        case 3:
                            options?.self.nightStartTime = time
                        default:
                            options?.self.morningStartTime = time
                        }
                        print("updateSavedTime: Options \(String(describing: options))")
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
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    date = options?.afternoonStartTime
                case 2:
                    date = options?.eveningStartTime
                case 3:
                    date = options?.nightStartTime
                default:
                    date = options?.morningStartTime
                }
            }
        }
        return date
    }
    
    //MARK: - Adjust Notifications
    //This is the one to run when setting up a brand new notification
    func scheduleNewNotification(title: String, notes: String?, segment: Int, uuidString: String) {
        
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
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    case 2:
                        if (options?.eveningNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    case 3:
                        if (options?.nightNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    default:
                        if (options?.morningNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    }
                }
            }
            
        }
    }
    
    func createNotification(title: String, notes: String?, segment: Int, uuidString: String) {
        print("createNotification running")
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.threadIdentifier = String(segment)
        
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
        dateComponents.calendar = Calendar.current
        self.loadOptions()
        
        switch segment {
        case 1:
            if let time = self.timeArray[1] {
                dateComponents.hour = getHour(date: getTime(timePeriod: 1, timeOption: time))
                dateComponents.minute = getMinute(date: getTime(timePeriod: 1, timeOption: time))
            }
        case 2:
            if let time = self.timeArray[2] {
                dateComponents.hour = getHour(date: getTime(timePeriod: 2, timeOption: time))
                dateComponents.minute = getMinute(date: getTime(timePeriod: 2, timeOption: time))
            }
        case 3:
            if let time = self.timeArray[3] {
                dateComponents.hour = getHour(date: getTime(timePeriod: 3, timeOption: time))
                dateComponents.minute = getMinute(date: getTime(timePeriod: 3, timeOption: time))
            }
        default:
            if let time = self.timeArray[0] {
                dateComponents.hour = getHour(date: getTime(timePeriod: 0, timeOption: time))
                dateComponents.minute = getMinute(date: getTime(timePeriod: 0, timeOption: time))
            }
        }
        
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
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                var uuidStrings: [String] = []
                let realm = try! Realm()
                let items = realm.objects(Items.self).filter("segment = \(segment)")
                for item in 0..<items.count {
                    uuidStrings.append(items[item].uuidString)
                }
                //Might need to move this. But lets try it
                self.removeNotification(uuidString: uuidStrings)
            }
        }
        
    }
    
    func enableNotificationsForSegment(segment: Int) {
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                let items = realm.objects(Items.self).filter("segment = \(segment)")
                for item in 0..<items.count {
                    self.scheduleNewNotification(title: items[item].title!, notes: items[item].notes, segment: items[item].segment, uuidString: items[item].uuidString)
                }
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
    
    var timeArray: [Date?] = []
    
    //Load Options
    func loadOptions() {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                //self.optionsObject = options
                self.timeArray = [options?.morningStartTime, options?.afternoonStartTime, options?.eveningStartTime, options?.nightStartTime]
            }
        }
    }

}
