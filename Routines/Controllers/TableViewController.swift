//
//  TableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import UserNotifications
import UserNotificationsUI

class TableViewController: SwipeTableViewController{
    
    @IBAction func unwindToTableViewController(segue:UIStoryboardSegue){}
    
    let realmDispatchQueueLabel: String = "background"
    
//    // Get the default Realm
//    let realm = try! Realm()
//    var items: Results<Items>?
//
//    //TODO: This is a bit of a mess for readability
//    var segmentedItems: Results<Items>?
//
//    //Options Properties
//    var optionsObject: Options?
    
    let optionsKey = "optionsKey"
    
    let segmentStringArray: [String] = ["Morning", "Afternoon", "Evening", "Night", "All Day"]
    
    //Set segment after adding an item
    var passedSegment: Int?
    func changeSegment(segment: Int?) {
        if let newSegment = segment {
            passedSegment = nil
            self.tabBarController?.selectedIndex = newSegment
        }
    }
    
    //Footer view
    let footerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load options
        //loadOptions()
        
        footerView.backgroundColor = .clear
        self.tableView.tableFooterView = footerView
        
        setViewBackgroundGraphic()
        
        //items = loadData()

        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //self.tabBarController?.delegate = self
        //self.navigationController?.delegate = self
//        guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
//        segmentedItems = loadItems(segment: selectedTab)
//        print("Selected tab is \(selectedTab)")
        
        requestNotificationPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //checkIfFirstItemAdded()
        self.tabBarController?.tabBar.isHidden = false
        updateBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
        //segmentedItems = loadItems(segment: selectedTab)
        print("Selected tab is \(selectedTab)")
        reloadTableView()
        print("viewDidAppear")
        changeSegment(segment: passedSegment)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Items.self).filter("segment = \(section)").count
            }
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                cell.textLabel?.text = realm.objects(Items.self).filter("segment = \(indexPath.section)")[indexPath.row].title
                
            }
        }
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addSegue" {
            
            let destination = segue.destination as! AddTableViewController
            //set segment based on current tab
            guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
            destination.editingSegment = selectedTab
            //Set right bar item as "Save"
            destination.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destination, action: #selector(destination.saveButtonPressed))
            //Disable button until all values are filled
            destination.navigationItem.rightBarButtonItem?.isEnabled = false
        }

        if segue.identifier == "editSegue" {
            let destination = segue.destination as! AddTableViewController
            //Set right bar item as "Save"
            destination.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destination, action: #selector(destination.saveButtonPressed))
            //Disable button until a value is changed
            destination.navigationItem.rightBarButtonItem?.isEnabled = false
            //pass in current item
            if let indexPath = tableView.indexPathForSelectedRow {
                DispatchQueue(label: realmDispatchQueueLabel).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        destination.item = realm.objects(Items.self).filter("segment = \(indexPath.section)")[indexPath.row]
                    }
                }
            }
        }
    }
    
    //MARK: - Model Manipulation Methods
    
//    func loadData() -> Results<Items> {
//        return realm.objects(Items.self)
//    }
    
    //Filter items to relevant segment and return those items
//    func loadItems(segment: Int) -> Results<Items> {
//        guard let filteredItems = items?.filter("segment = \(segment)") else { fatalError() }
//        print("loadItems run")
//        //self.tableView.reloadData()
//        return filteredItems
//    }
    
    //Override empty delete func from super
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try! realm.write {
                        let item = realm.objects(Items.self).filter("segment = \(indexPath.section)")[indexPath.row]
                        realm.delete(item)
                    }
                }
            }
        }
        self.updateBadge()
    }
    
    //TODO: Animated reload would be nice
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    //Set background graphic
    func setViewBackgroundGraphic() {
        
        //let imageSize:CGFloat = UIScreen.main.bounds.width * 0.893
        
        let backgroundImageView = UIImageView()
        let backgroundImage = UIImage(imageLiteralResourceName: "inlay")
        
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFit
        
        self.tableView.backgroundView = backgroundImageView
        
    }
    
    //Update tab bar badge counts
    func updateBadge() {
        
        if let tabs = self.tabBarController?.tabBar.items {
            
            for tab in 0..<tabs.count {
                let count = getSegmentCount(segment: tab)
                if count > 0 {
                    tabs[tab].badgeValue = "\(count)"
                } else {
                    tabs[tab].badgeValue = nil
                }
            }
        }
    }
    
    func getSegmentCount(segment: Int) -> Int {
        var count = Int()
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Items.self).filter("segment = \(segment)").count
            }
        }
        return count
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
            DispatchQueue(label: realmDispatchQueueLabel).async {
                autoreleasepool {
                    let realm = try! Realm()
                    let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                    dateComponents.hour = self.getHour(date: self.getOptionTimes(timePeriod: 1, timeOption: options?.afternoonStartTime))
                    dateComponents.minute = self.getMinute(date: self.getOptionTimes(timePeriod: 1, timeOption: options?.afternoonStartTime))
                }
            }
        case 2:
            DispatchQueue(label: realmDispatchQueueLabel).async {
                autoreleasepool {
                    let realm = try! Realm()
                    let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                    dateComponents.hour = self.getHour(date: self.getOptionTimes(timePeriod: 2, timeOption: options?.eveningStartTime))
                    dateComponents.minute = self.getMinute(date: self.getOptionTimes(timePeriod: 2, timeOption: options?.eveningStartTime))
                }
            }
        case 3:
            DispatchQueue(label: realmDispatchQueueLabel).async {
                autoreleasepool {
                    let realm = try! Realm()
                    let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                    dateComponents.hour = self.getHour(date: self.getOptionTimes(timePeriod: 3, timeOption: options?.nightStartTime))
                    dateComponents.minute = self.getMinute(date: self.getOptionTimes(timePeriod: 3, timeOption: options?.nightStartTime))
                }
            }
        default:
            DispatchQueue(label: realmDispatchQueueLabel).async {
                autoreleasepool {
                    let realm = try! Realm()
                    let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                    dateComponents.hour = self.getHour(date: self.getOptionTimes(timePeriod: 0, timeOption: options?.morningStartTime))
                    dateComponents.minute = self.getMinute(date: self.getOptionTimes(timePeriod: 0, timeOption: options?.morningStartTime))
                }
            }
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
    
    //MARK: - Options Realm
    
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
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try realm.write {
                        item.uuidString = uuidString
                    }
                } catch {
                    print("failed to update UUID for item")
                }
            }
        }
    }
    
}
