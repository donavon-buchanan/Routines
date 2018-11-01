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

class AddTableViewController: UITableViewController, UITextViewDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var segmentSelection: UISegmentedControl!
    @IBOutlet weak var notesTextView: UITextView!
    
    var item : Items?
    
    //segment from add segue
    var editingSegment: Int?
    
    //var itemTitle : String?
    
    // Get the default Realm
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        //If item is loaded, fill in values for editing
        if item != nil {
            taskTextField.text = item?.title
            segmentSelection.selectedSegmentIndex = item?.segment ?? 0
            notesTextView.text = item?.notes
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOptions()
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
        addNewItem()
        self.tabBarController?.tabBar.isHidden = false
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TableViewController
        destinationVC.passedSegment = segmentSelection.selectedSegmentIndex
    }
    
    func addNewItem() {
        //if it's a new item, add it as new to the realm
        //otherwise, update the existing item
        if item == nil {
            let newItem = Items()
            newItem.title = taskTextField.text
            newItem.dateModified = Date()
            newItem.segment = segmentSelection.selectedSegmentIndex
            newItem.notes = notesTextView.text
            
            //save to realm
            saveItem(item: newItem)
        } else {
            updateItem()
        }
    }
    
    func saveItem(item: Items) {
        do {
            try realm.write {
                createNotification(notificationItem: item)
                realm.add(item)
            }
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
    func updateItem() {
        do {
            try realm.write {
                item!.title = taskTextField.text
                item!.dateModified = Date()
                item!.segment = segmentSelection.selectedSegmentIndex
                item!.notes = notesTextView.text
                removeNotification(item: self.item!)
                createNotification(notificationItem: self.item!)
            }
        } catch {
            print("Error updating item: \(error)")
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
    
    func checkForNotificationAuth() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            //DO not schedule notifications if not authorized
            guard settings.authorizationStatus == .authorized else {
                self.requestNotificationPermission()
                return
            }
            if settings.alertSetting == .enabled {
                //Schedule an alert-only notification
                
            } else {
                //Schedule a notification with a badge and sound
                
            }
            
        }
    }
    
    func checkNotificationOptions(notificationItem: Items) -> Bool {
        var notificationsEnabled: Bool = false
        switch notificationItem.segment {
        case 0:
            if let enabled = optionsObject?.morningNotificationsOn {
                notificationsEnabled = enabled
            }
        case 1:
            if let enabled = optionsObject?.afternoonNotificationsOn {
                notificationsEnabled = enabled
            }
        case 2:
            if let enabled = optionsObject?.eveningNotificationsOn {
                notificationsEnabled = enabled
            }
        case 3:
            if let enabled = optionsObject?.nightNotificationsOn {
                notificationsEnabled = enabled
            }
        default:
            notificationsEnabled = false
        }
        return notificationsEnabled
    }
    
    func createNotification(notificationItem: Items) {
        
        if checkNotificationOptions(notificationItem: notificationItem) {
            let content = UNMutableNotificationContent()
            guard case content.title = notificationItem.title else { return }
            if let notes = notificationItem.notes {
                content.body = notes
            }
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            switch notificationItem.segment {
            case 1:
                dateComponents.hour = getHour(date: getOptionTimes(timePeriod: 1, timeOption: optionsObject?.afternoonStartTime))
                dateComponents.minute = getMinute(date: getOptionTimes(timePeriod: 1, timeOption: optionsObject?.afternoonStartTime))
            case 2:
                dateComponents.hour = getHour(date: getOptionTimes(timePeriod: 2, timeOption: optionsObject?.eveningStartTime))
                dateComponents.minute = getMinute(date: getOptionTimes(timePeriod: 2, timeOption: optionsObject?.eveningStartTime))
            case 3:
                dateComponents.hour = getHour(date: getOptionTimes(timePeriod: 3, timeOption: optionsObject?.nightStartTime))
                dateComponents.minute = getMinute(date: getOptionTimes(timePeriod: 3, timeOption: optionsObject?.nightStartTime))
            default:
                dateComponents.hour = getHour(date: getOptionTimes(timePeriod: 0, timeOption: optionsObject?.morningStartTime))
                dateComponents.minute = getMinute(date: getOptionTimes(timePeriod: 0, timeOption: optionsObject?.morningStartTime))
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
        
    }
    
    func getOptionTimes(timePeriod: Int, timeOption: Date?) -> Date {
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
    
    func removeNotification(item: Items) {
        if let uuidString = item.uuidString {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [uuidString])
        }
    }
    
    //MARK: - Options Realm
    
    //Options Properties
    let optionsRealm = try! Realm()
    var optionsObject: Options?
    //var firstItemAdded: Bool?
    let optionsKey = "optionsKey"
    
    //Load Options
    func loadOptions() {
        optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey)
    }

}
