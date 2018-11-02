//
//  OptionsTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import RealmSwift

class OptionsTableViewController: UITableViewController {
    
    @IBOutlet weak var morningSwitch: UISwitch!
    @IBOutlet weak var afternoonSwitch: UISwitch!
    @IBOutlet weak var eveningSwitch: UISwitch!
    @IBOutlet weak var nightSwitch: UISwitch!
    
    @IBOutlet weak var morningSubLabel: UILabel!
    @IBOutlet weak var afternoonSubLabel: UILabel!
    @IBOutlet weak var eveningSubLabel: UILabel!
    @IBOutlet weak var nightSubLabel: UILabel!
    
    
    @IBAction func notificationSwitchToggled(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            print("Morning Switch Toggled \(sender.isOn)")
            addRemoveNotificationsOnToggle(segment: 0, isOn: sender.isOn)
            updateNotificationOptions()
        case 1:
            print("Afternoon Switch Toggled \(sender.isOn)")
            //addRemoveNotificationsOnToggle(segment: 1, isOn: sender.isOn)
            updateNotificationOptions()
        case 2:
            print("Evening Switch Toggled \(sender.isOn)")
            //addRemoveNotificationsOnToggle(segment: 2, isOn: sender.isOn)
            updateNotificationOptions()
        case 3:
            print("Night Switch Toggled \(sender.isOn)")
            //addRemoveNotificationsOnToggle(segment: 3, isOn: sender.isOn)
            updateNotificationOptions()
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //loadOptions()
        
//        //Check that everything matches up
//        DispatchQueue.main.async {
//            self.addRemoveNotificationsOnToggle(segment: 0, isOn: self.morningSwitch.isOn)
//            self.addRemoveNotificationsOnToggle(segment: 1, isOn: self.afternoonSwitch.isOn)
//            self.addRemoveNotificationsOnToggle(segment: 2, isOn: self.eveningSwitch.isOn)
//            self.addRemoveNotificationsOnToggle(segment: 3, isOn: self.nightSwitch.isOn)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadOptions()
        setUpUI()
        //loadItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 4
        case 2:
            numberOfRows = 1
        default:
            numberOfRows = 0
        }
        
        return numberOfRows
    }
    
    //Make the full width of the cell toggle the switch along with typical haptic
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                print("Tapped Morning Cell")
                let isOn = !self.morningSwitch.isOn
                self.morningSwitch.setOn(isOn, animated: true)
                addRemoveNotificationsOnToggle(segment: 0, isOn: isOn)
                print("Morning switch is now set to: \(morningSwitch.isOn)")
                updateNotificationOptions()
                haptic.impactOccurred()
            case 1:
                print("Tapped Afternoon Cell")
                let isOn = !self.afternoonSwitch.isOn
                self.afternoonSwitch.setOn(isOn, animated: true)
                addRemoveNotificationsOnToggle(segment: 1, isOn: isOn)
                print("Afternoon switch is now set to: \(afternoonSwitch.isOn)")
                updateNotificationOptions()
                haptic.impactOccurred()
            case 2:
                print("Tapped Evening Cell")
                let isOn = !self.eveningSwitch.isOn
                self.eveningSwitch.setOn(isOn, animated: true)
                addRemoveNotificationsOnToggle(segment: 2, isOn: isOn)
                print("Evening switch is now set to: \(eveningSwitch.isOn)")
                updateNotificationOptions()
                haptic.impactOccurred()
            case 3:
                print("Tapped Night Cell")
                let isOn = !self.nightSwitch.isOn
                self.nightSwitch.setOn(isOn, animated: true)
                addRemoveNotificationsOnToggle(segment: 3, isOn: isOn)
                print("Night switch is now set to: \(nightSwitch.isOn)")
                updateNotificationOptions()
                haptic.impactOccurred()
            default:
                break
            }
        }
    }

    //MARK: - Options Realm
    
//    //Options Properties
//    let optionsRealm = try! Realm()
//    var optionsObject: Options?
//    //var firstItemAdded: Bool?
//    let optionsKey = "optionsKey"
//
//    //Load Options
//    func loadOptions() {
//        optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey)
//    }
    
    func updateNotificationOptions() {
        do {
            try self.optionsRealm.write {
                print("saving notification option")
                self.optionsObject?.morningNotificationsOn = morningSwitch.isOn
                self.optionsObject?.afternoonNotificationsOn = afternoonSwitch.isOn
                self.optionsObject?.eveningNotificationsOn = eveningSwitch.isOn
                self.optionsObject?.nightNotificationsOn = nightSwitch.isOn
            }
        } catch {
            print("failed to update notification saved bools")
        }
    }
    
    func setUpUI() {
        print("Setting up UI")
        //Set Switches
        morningSwitch.setOn(getNotificationBool(notificationOption: optionsObject?.morningNotificationsOn), animated: false)
        afternoonSwitch.setOn(getNotificationBool(notificationOption: optionsObject?.afternoonNotificationsOn), animated: false)
        eveningSwitch.setOn(getNotificationBool(notificationOption: optionsObject?.eveningNotificationsOn), animated: false)
        nightSwitch.setOn(getNotificationBool(notificationOption: optionsObject?.nightNotificationsOn), animated: false)
        
        //Set Sub Labels
        morningSubLabel.text = getOptionTimes(timePeriod: 0, timeOption: optionsObject?.morningStartTime)
        afternoonSubLabel.text = getOptionTimes(timePeriod: 1, timeOption: optionsObject?.afternoonStartTime)
        eveningSubLabel.text = getOptionTimes(timePeriod: 2, timeOption: optionsObject?.eveningStartTime)
        nightSubLabel.text = getOptionTimes(timePeriod: 3, timeOption: optionsObject?.nightStartTime)
    }
    
    func getNotificationBool(notificationOption: Bool?) -> Bool {
        var isOn = false
        if let notificationIsOn = notificationOption {
            isOn = notificationIsOn
        }
        return isOn
    }
    
    func getOptionTimes(timePeriod: Int, timeOption: Date?) -> String {
        var time: String = " "
        let periods = ["morning", "afternoon", "evening", "night"]
        let defaultTimeStrings = ["07:00 AM", "12:00 PM", "5:00 PM", "9:00 PM"]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        if let dateTime = timeOption {
            
            time = "Your \(periods[timePeriod]) begins at \(dateFormatter.string(from: dateTime))"
        } else {
            
            let defaultTime = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
            
            time = "Your \(periods[timePeriod]) begins at \(dateFormatter.string(from: defaultTime))"
        }
        
        return time
    }
    
    func getOptionTimesAsDate(timePeriod: Int, timeOption: Date?) -> Date {
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
    
    func updateItemUUID(item: Items, uuidString: String) {
        do {
            try realm.write {
                item.uuidString = uuidString
            }
        } catch {
            print("failed to update UUID for item")
        }
    }
    
    //MARK: - Manage Notifications

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        //Request permission to display alerts and play sounds
        if #available(iOS 12.0, *) {
            center.requestAuthorization(options: [.alert, .sound, .badge, .provisional, .providesAppNotificationSettings]) { (granted, error) in
                // Enable or disable features based on authorization.
                if !granted {
                    return
                }
            }
        } else {
            // Fallback on earlier versions
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Enable or disable features based on authorization.
                if !granted {
                    return
                }
            }
        }
    }

    func checkForNotificationAuth(notificationItem: Items) {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getNotificationSettings { (settings) in
            //DO not schedule notifications if not authorized
            guard settings.authorizationStatus == .authorized else {
                //self.requestNotificationPermission()
                return
            }
            if settings.alertSetting == .enabled {
                //Schedule an alert-only notification
                self.createNotification(notificationItem: notificationItem)

            } else {
                //Schedule a notification with a badge and sound

            }

        }
    }

    func createNotification(notificationItem: Items) {
        let content = UNMutableNotificationContent()
        guard case content.title = notificationItem.title else { return }
        if let notes = notificationItem.notes {
            content.body = notes
        }

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        switch notificationItem.segment {
        case 1:
            dateComponents.hour = getHour(date: getOptionTimesAsDate(timePeriod: 1, timeOption: optionsObject?.afternoonStartTime))
            dateComponents.minute = getMinute(date: getOptionTimesAsDate(timePeriod: 1, timeOption: optionsObject?.afternoonStartTime))
        case 2:
            dateComponents.hour = getHour(date: getOptionTimesAsDate(timePeriod: 2, timeOption: optionsObject?.eveningStartTime))
            dateComponents.minute = getMinute(date: getOptionTimesAsDate(timePeriod: 2, timeOption: optionsObject?.eveningStartTime))
        case 3:
            dateComponents.hour = getHour(date: getOptionTimesAsDate(timePeriod: 3, timeOption: optionsObject?.nightStartTime))
            dateComponents.minute = getMinute(date: getOptionTimesAsDate(timePeriod: 3, timeOption: optionsObject?.nightStartTime))
        default:
            dateComponents.hour = getHour(date: getOptionTimesAsDate(timePeriod: 0, timeOption: optionsObject?.morningStartTime))
            dateComponents.minute = getMinute(date: getOptionTimesAsDate(timePeriod: 0, timeOption: optionsObject?.morningStartTime))
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        //Create the request
        let uuidString = UUID().uuidString
        updateItemUUID(item: notificationItem, uuidString: uuidString)
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        //Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                //TODO: handle notification errors
            }
        }

    }

    func scheduleNewNotification(item: Items) {
        checkForNotificationAuth(notificationItem: item)
    }

    func removeNotification(item: Items) {
        if let uuidString = item.uuidString {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [uuidString])
        }
    }

    func removeNotifications(uuidStringArray: [String]?) {
        if let uuidStrings = uuidStringArray {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: uuidStrings)
        }
    }

    func addRemoveNotificationsOnToggle(segment: Int, isOn: Bool) {
        let items = filterItems(segment: segment, items: self.items)
        if isOn {
            print("Turning notifications on for segment \(segment)")
            for item in 0..<items.count {
                scheduleNewNotification(item: items[item])
            }
        } else {
            print("Turning notifications off for segment \(segment)")
            var uuidStrings: [String]?
            for item in 0..<items.count {
                if let idString = items[item].uuidString {
                    uuidStrings?.append(idString)
                }
            }
            removeNotifications(uuidStringArray: uuidStrings)
        }
    }

    //MARK: Items Realm

//    // Get the default Realm
//    let realm = try! Realm()
//    var items: Results<Items>?
//
//    func loadItems() {
//        items = realm.objects(Items.self)
//    }
//
//    //Filter items to relevant segment and return those items
//    func filterItems(segment: Int, items: Results<Items>?) -> Results<Items> {
//        guard let filteredItems = items?.filter("segment = \(segment)") else { fatalError() }
//        print("filterItems run")
//        return filteredItems
//    }

}
