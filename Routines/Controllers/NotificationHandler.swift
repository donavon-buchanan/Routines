//
//  NotificationHandler.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/4/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import UserNotificationsUI
import UserNotifications
import RealmSwift

class NotificationHandler: UNUserNotificationCenter, UNUserNotificationCenterDelegate {
    
    func requestNotificationPermission() {
        print("running Request notification permission")
        let center = UNUserNotificationCenter.current()
        //Request permission to display alerts and play sounds
        if #available(iOS 12.0, *) {
            center.requestAuthorization(options: [.alert, .sound, .badge, .provisional, .providesAppNotificationSettings]) { (granted, error) in
                // Enable or disable features based on authorization.
                if !granted {
                    print("requestNotificationPermission denied")
                    return
                }
            }
        } else {
            // Fallback on earlier versions
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Enable or disable features based on authorization.
                if !granted {
                    print("requestNotificationPermission denied")
                    return
                }
            }
        }
    }
    
    
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
            
            if settings.alertSetting == .enabled {
                print("creating alert style notification")
                //Schedule an alert-only notification
                //TODO: Check if segment notification option is on or off
                self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                
            } else {
                //Schedule a notification with a badge and sound
                print("not an alert")
            }
            
        }
    }
    
    func createNotification(title: String, notes: String?, segment: Int, uuidString: String) {
        print("createNotification running")
        let content = UNMutableNotificationContent()
        content.title = title
        
        if let notesText = notes {
            content.body = notesText
        }
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        self.loadOptions()
        //TODO: Error is here. Load these times with the view since they won't be changing. Then refernce those variables instead of the realm object
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
    
    func removeNotification(uuidString: [String]) {
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
