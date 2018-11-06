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
    var timeArray: [Date?] = []
    //segment from add segue
    var editingSegment: Int?
    
    var uuidString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadOptions()
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
            taskTextField.backgroundColor = UIColor.groupTableViewBackground
        }
        
        if notesTextView.hasText == false {
            notesTextView.backgroundColor = UIColor.groupTableViewBackground
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
        
        notesTextView.backgroundColor = UIColor.groupTableViewBackground
    }
    
    @objc func viewTapped(_ aRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        
        if textView.hasText {
            textView.backgroundColor = .white
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor.groupTableViewBackground
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.hasText {
            textField.backgroundColor = .white
        }
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
            newItem.dateModified = date
            newItem.segment = segment
            newItem.notes = notes
            newItem.uuidString = uuidString
            //save to realm
            saveItem(item: newItem)
            scheduleNewNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
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
                self.item!.dateModified = Date()
                self.item!.segment = self.segmentSelection.selectedSegmentIndex
                self.item!.notes = self.notesTextView.text
            }
        } catch {
            print("Error updating item: \(error)")
        }
        self.removeNotification(uuidString: self.item!.uuidString)
        self.scheduleNewNotification(title: self.item!.title!, notes: self.item!.notes, segment: self.item!.segment, uuidString: self.item!.uuidString)
    }
    
    //MARK: - Manage Notifications
    
    func scheduleNewNotification(title: String, notes: String?, segment: Int, uuidString: String) {
        
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)
                switch segment {
                case 1:
                    if !(options?.afternoonNotificationsOn)! {
                        print("Afternoon Notifications toggled off. Aborting")
                        return
                    }
                case 2:
                    if !(options?.eveningNotificationsOn)! {
                        print("Afternoon Notifications toggled off. Aborting")
                        return
                    }
                case 3:
                    if !(options?.nightNotificationsOn)! {
                        print("Afternoon Notifications toggled off. Aborting")
                        return
                    }
                default:
                    if !(options?.morningNotificationsOn)! {
                        print("Afternoon Notifications toggled off. Aborting")
                        return
                    }
                }
            }
        }
        
        print("running scheduleNewNotification")
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            //DO not schedule notifications if not authorized
            guard settings.authorizationStatus == .authorized else {
                //self.requestNotificationPermission()
                print("Authorization status has changed to unauthorized for notifications")
                return
            }
            
            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
            
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
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
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
    
    func removeNotification(uuidString: String) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [uuidString])
    }
    
    //MARK: - Options Realm
    
    //Options Properties
    //var optionsObject: Options?
    //var firstItemAdded: Bool?
    let optionsKey = "optionsKey"
    
    //Load Options
    func loadOptions() {
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                //self.optionsObject = options
                self.timeArray = [options?.morningStartTime, options?.afternoonStartTime, options?.eveningStartTime, options?.nightStartTime]
            }
        }
    }
    
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
    
//    func updateItemUUID(item: Items, uuidString: String) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                do {
//                    try realm.write {
//                        item.uuidString = uuidString
//                    }
//                } catch {
//                    print("failed to update UUID for item")
//                }
//            }
//        }
//    }

}
