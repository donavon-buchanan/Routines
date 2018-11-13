//
//  AddTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/23/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import UserNotificationsUI

class AddTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var segmentSelection: UISegmentedControl!
    @IBOutlet weak var notesTextView: UITextView!
    
    let realmDispatchQueueLabel: String = "background"
    
    var item : Items?
    //var timeArray: [DateComponents?] = []
    //segment from add segue
    var editingSegment: Int?
    
    var uuidString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        //If item is loaded, fill in values for editing
        if item != nil {
            print("item was non-nil")
            taskTextField.text = item?.title
            segmentSelection.selectedSegmentIndex = item?.segment ?? 0
            notesTextView.text = item?.notes
            self.uuidString = (item?.uuidString)!
            //print("Item's uuidString is \((item?.uuidString)!)")
        } else {
            self.uuidString = UUID().uuidString
            print("new item uuidString: \(self.uuidString)")
        }
        
        //load in segment from add segue
        if let currentSegmentSelection = editingSegment {
            segmentSelection.selectedSegmentIndex = currentSegmentSelection
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        taskTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        segmentSelection.addTarget(self, action: #selector(self.textFieldDidChange), for: .valueChanged)
        notesTextView.delegate = self
        taskTextField.delegate = self
        
        notesTextView.layer.cornerRadius = 6
        notesTextView.layer.masksToBounds = true
        notesTextView.layer.borderWidth = 0.25
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        if taskTextField.hasText == false {
            //taskTextField.backgroundColor = UIColor.groupTableViewBackground
        }
        
        if notesTextView.hasText == false {
            //notesTextView.backgroundColor = UIColor.groupTableViewBackground
        }
        
        //Add tap gesture for editing notes
        let textFieldTap = UITapGestureRecognizer(target: self, action: #selector(setNotesEditable))
        self.notesTextView.addGestureRecognizer(textFieldTap)
        
        //add a tap recognizer to stop editing when tapping outside the textView
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(viewTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc func setNotesEditable(_ aRecognizer: UITapGestureRecognizer) {
        self.notesTextView.dataDetectorTypes = []
        self.notesTextView.isEditable = true
        self.notesTextView.becomeFirstResponder()
        
        //notesTextView.backgroundColor = UIColor.groupTableViewBackground
    }
    
    @objc func viewTapped(_ aRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        
        if textView.hasText {
            //textView.backgroundColor = .white
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //textView.backgroundColor = UIColor.groupTableViewBackground
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.hasText {
            //textField.backgroundColor = .white
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if let destinationVC = segue.destination as? TableViewController {
//            destinationVC.setSegment = segmentSelection.selectedSegmentIndex
//        }
//    }
    
    @objc func textFieldDidChange() {
        if taskTextField.text!.count > 0 {
           //itemTitle = taskTextField.text!
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            //itemTitle = nil
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if self.item != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @objc func saveButtonPressed() {
        addNewItem(title: self.taskTextField.text!, date: Date(), segment: self.segmentSelection.selectedSegmentIndex, notes: self.notesTextView.text, uuidString: self.uuidString)
        //print("Adding item with uuidString: \(self.uuidString)")
        self.tabBarController?.tabBar.isHidden = false
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("running prepare for segue")
        let destinationVC = segue.destination as! TableViewController
        destinationVC.passedSegment = segmentSelection.selectedSegmentIndex
        //scheduleNewNotification(title: taskTextField.text!, notes: notesTextView.text, segment: segmentSelection.selectedSegmentIndex, uuidString: self.uuidString)
    }
    
    func addNewItem(title: String, date: Date, segment: Int, notes: String, uuidString: String) {
        print("Running addNewItem")
        //if it's a new item, add it as new to the realm
        //otherwise, update the existing item
        if self.item == nil {
            let newItem = Items()
            newItem.title = title
            newItem.segment = segment
            if segment <= getCurrentSegmentFromTime() {
                print("Adding new item for tomorrow")
                newItem.dateModified = Date().startOfNextDay
            } else {
                print("Adding new item for today")
                newItem.dateModified = Date()
            }
            newItem.notes = notes
            
            //save to realm
            saveItem(item: newItem)
            if getAutoSnoozeStatus() {
                scheduleAutoSnoozeNotifications(title: title, notes: notes, uuidString: newItem.uuidString, afternoonUUID: newItem.afternoonUUID, eveningUUID: newItem.eveningUUID, nightUUID: newItem.nightUUID, firstDate: newItem.dateModified!)
            } else {
                scheduleNewNotification(title: title, notes: notes, segment: segment, uuidString: newItem.uuidString, firstDate: newItem.dateModified!)
            }
        } else {
            updateItem()
        }
    }
    
    func saveItem(item: Items) {
        print("Running saveItem")
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
    func updateItem() {
        let realm = try! Realm()
        do {
            try realm.write {
                self.item!.title = self.taskTextField.text
                //For Smart Snooze
                if self.segmentSelection.selectedSegmentIndex <= getCurrentSegmentFromTime() {
                    print("Updating item for tomorrow")
                    self.item!.dateModified = Date().startOfNextDay
                } else {
                    print("Updating item for today")
                    self.item!.dateModified = Date()
                }
                self.item!.segment = self.segmentSelection.selectedSegmentIndex
                self.item!.notes = self.notesTextView.text
            }
        } catch {
            print("Error updating item: \(error)")
        }
        self.removeNotification(uuidString: [self.item!.uuidString, self.item!.afternoonUUID, self.item!.eveningUUID, self.item!.nightUUID])
        
        if getAutoSnoozeStatus() {
            scheduleAutoSnoozeNotifications(title: self.item!.title!, notes: self.item!.notes, uuidString: self.item!.uuidString, afternoonUUID: self.item!.afternoonUUID, eveningUUID: self.item!.eveningUUID, nightUUID: self.item!.nightUUID, firstDate: self.item!.dateModified!)
        } else {
            self.scheduleNewNotification(title: self.item!.title!, notes: self.item!.notes, segment: self.item!.segment, uuidString: self.item!.uuidString, firstDate: self.item!.dateModified!)
        }
    }
    
    //MARK: - Manage Notifications
    
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
    
    //TODO: This is near identical to another function here
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
    
    func scheduleAutoSnoozeNotifications(title: String, notes: String?, uuidString: String, afternoonUUID: String, eveningUUID: String, nightUUID: String, firstDate: Date) {
        
        if getSegmentNotificationOption(segment: 0) {
            scheduleNewNotification(title: title, notes: notes, segment: 0, uuidString: uuidString, firstDate: firstDate)
        }
        if getSegmentNotificationOption(segment: 1) {
            scheduleNewNotification(title: title, notes: notes, segment: 1, uuidString: afternoonUUID, firstDate: firstDate)
        }
        if getSegmentNotificationOption(segment: 2) {
            scheduleNewNotification(title: title, notes: notes, segment: 2, uuidString: eveningUUID, firstDate: firstDate)
        }
        if getSegmentNotificationOption(segment: 3) {
            scheduleNewNotification(title: title, notes: notes, segment: 3, uuidString: nightUUID, firstDate: firstDate)
        }
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
    
    func removeNotification(uuidString: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidString)
    }
    
    //MARK: - Options Realm
    
    //Options Properties
    //var optionsObject: Options?
    //var firstItemAdded: Bool?
    let optionsKey = "optionsKey"
    
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
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    switch segment {
                    case 1:
                        hour = options.afternoonHour
                    case 2:
                        hour = options.eveningHour
                    case 3:
                        hour = options.nightHour
                    default:
                        hour = options.morningHour
                    }
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
    func getSmartSnoozeStatus() -> Bool {
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
    
    func getDateFromComponents(hour: Int, minute: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.calendar = Calendar.autoupdatingCurrent
        dateComponent.timeZone = TimeZone.autoupdatingCurrent
        dateComponent.hour = hour
        dateComponent.minute = minute
        return dateComponent.date!
    }

}
