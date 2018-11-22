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
import NotificationCenter

class TableViewController: SwipeTableViewController, UINavigationControllerDelegate, UITabBarControllerDelegate {
    
    @IBAction func unwindToTableViewController(segue:UIStoryboardSegue){}
    @IBOutlet var settingsBarButtonItem: UIBarButtonItem!
    @IBOutlet var addbarButtonItem: UIBarButtonItem!
    
    
    @IBAction func longPressToEdit(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if let count = items?.count {
                if count > 0 {
                    if !self.tableView.isEditing {
                        self.tableView.setEditing(true, animated: true)
                        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(showClearAlert))
                        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedRows))
                        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEdit))
                        self.navigationItem.rightBarButtonItems = [doneButton, trashButton]
                    } else {
                        endEdit()
                    }
                } else {
                    endEdit()
                }
            } else {
                endEdit()
            }
        }
    }
    
    @objc func endEdit() {
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.leftBarButtonItem = settingsBarButtonItem
        self.navigationItem.rightBarButtonItems = [addbarButtonItem]
    }
    
    let realmDispatchQueueLabel: String = "background"
    
    //Set segment after adding an item
    var passedSegment: Int?
    func changeSegment(segment: Int?) {
        if let newSegment = segment {
            passedSegment = nil
            self.tabBarController?.selectedIndex = newSegment
            saveSelectedTab(index: newSegment)
        }
    }
    
    //Footer view
    let footerView = UIView()
    //var selectedTab = 0

    override func viewDidLoad() {
        print("Running viewDidLoad")
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil )
        
        //center.delegate = self
        
        self.tabBarController?.delegate = self
        self.navigationController?.delegate = self
        self.segment = self.tabBarController?.selectedIndex ?? 0
        //TODO: Fade cells into top nav bar
        //self.tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        
        footerView.backgroundColor = .clear
        self.tableView.tableFooterView = footerView
        self.tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        
        setViewBackgroundGraphic()
        
        loadItems(segment: self.segment)
    }
    
    @objc func appBecameActive() {
        self.runAutoSnooze()
        removeDeliveredNotifications()
        updateBadge()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear")
        changeSegment(segment: passedSegment)
        runAutoSnooze()
        updateBadge()
        removeDeliveredNotifications()
        setNavTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear \n")
        reloadTableView()
        setAppearance(segment: self.segment)
    }
    
    func setNavTitle() {
        print("Setting table title")
        switch self.segment {
        case 1:
            self.title = "Afternoon"
        case 2:
            self.title = "Evening"
        case 3:
            self.title = "Night"
        default:
            self.title = "Morning"
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        saveSelectedTab(index: tabBarController.selectedIndex)
    }
    
    func saveSelectedTab(index: Int) {
        print("saving tab as index: \(index)")
        //let selectedIndex = self.tabBarController?.selectedIndex
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    do {
                        try realm.write {
                            options.selectedIndex = index
                        }
                    } catch {
                        print("Error saving selected tab")
                    }
                }
            }
        }
    }
    
    func getSelectedTab() -> Int {
        var index = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    index = options.selectedIndex
                }
            }
        }
        return index
    }
    
    
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        self.selectedTab = tabBarController.selectedIndex
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.items?.count ?? 0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = self.items?[indexPath.row].title
        if let subtitle = self.items?[indexPath.row].notes {
            if subtitle.count > 0 {
                cell.detailTextLabel?.text = subtitle
            } else {
                cell.detailTextLabel?.text = nil
            }
        }
        cell.textLabel?.theme_textColor = GlobalPicker.cellTextColors
        cell.theme_backgroundColor = GlobalPicker.backgroundColor
        let cellSelectedBackgroundView = UIView()
        cellSelectedBackgroundView.theme_backgroundColor = GlobalPicker.cellBackground
        cell.selectedBackgroundView = cellSelectedBackgroundView
        cell.multipleSelectionBackgroundView = cellSelectedBackgroundView
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//
//                try! realm.write {
//
//                }
//            }
//        }
//    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "editSegue" {
            if self.tableView.isEditing {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    @objc func showClearAlert() {
        
        var segmentName : String {
            let segment = self.segment
            switch segment {
            case 1:
                return "afternoon"
            case 2:
                return "evening"
            case 3:
                return "night"
            default:
                return "morning"
            }
        }
        
        let alert = UIAlertController(title: "Are you sure?", message: "This will clear all your \(segmentName) tasks at once.", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Do it!", style: .destructive) { (action) in
            self.clearAll()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(clearAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func clearAll() {
        self.items?.forEach({ (item) in
            DispatchQueue(label: self.realmDispatchQueueLabel).sync {
                autoreleasepool {
                    let realm = try! Realm()
                    try! realm.write {
                        self.removeNotification(uuidString: ["\(item.uuidString)0", "\(item.uuidString)1", "\(item.uuidString)2", "\(item.uuidString)3", item.uuidString])
                        realm.delete(item)
                    }
                    let indexPath = self.tableView.indexPathForRow(at: CGPoint(x: 0, y: 0))
                    self.tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.left)
                }
            }
        })
        endEdit()
        self.updateBadge()
    }
    
    @objc func deleteSelectedRows() {
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            indexPaths.forEach({ (indexPath) in
                updateModel(at: indexPath)
            })
            tableView.deleteRows(at: indexPaths, with: .left)
        }
    }

//    //Delay func
//    func delay(_ delay:Double, closure:@escaping ()->()) {
//        DispatchQueue.main.asyncAfter(
//            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
//    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addSegue" {
            
            let destination = segue.destination as! AddTableViewController
            //set segment based on current tab
            guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
            destination.editingSegment = selectedTab
        }

        if segue.identifier == "editSegue" {
            let destination = segue.destination as! AddTableViewController
            //pass in current item
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.item = items?[indexPath.row]
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
        //super.updateModel(at: indexPath)
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                do {
                    try! realm.write {
                        if let item = self.items?[indexPath.row] {
                            self.removeNotification(uuidString: ["\(item.uuidString)0", "\(item.uuidString)1", "\(item.uuidString)2", "\(item.uuidString)3", item.uuidString])
                            print("removing item with key: \(item.uuidString)")
                            realm.delete(item)
                        }
                    }
                }
            }
        }
        OptionsTableViewController().refreshNotifications()
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
        
        DispatchQueue.main.async {
            autoreleasepool {
                if let tabs = self.tabBarController?.tabBar.items {
                    
                    for tab in 0..<tabs.count {
                        let count = self.getCountForTab(tab)
                        print("Count for tab \(tab) is \(count)")
                        if count > 0 {
                            tabs[tab].badgeValue = "\(count)"
                        } else {
                            tabs[tab].badgeValue = nil
                        }
                    }
                }
            }
        }
        //AppDelegate().updateAppBadgeCount()
    }
    
    func getCountForTab(_ tab: Int) -> Int {
        let realm = try! Realm()
        return realm.objects(Items.self).filter("segment = %@ AND dateModified < %@",tab ,Date()).count
    }
    
    //MARK: - Manage Notifications
    
    let center = UNUserNotificationCenter.current()
    
    func removeNotification(uuidString: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidString)
    }
    
    func removeDeliveredNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { (notifications) in
            for notification in notifications {
                //TODO: If repeats, remove and then add again
                //Get the ID and then get the properties of the specific object
                //Need to get all the same notification functions used in other views to be able to create
                center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
            }
        }
    }
    
    //Notification Settings Screen
//    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
//        print("Opening settings")
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let optionsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsView") as! OptionsTableViewController
//        self.navigationController?.pushViewController(optionsViewController, animated: true)
//    }
    
    
    //MARK: - Realm
    
    // Get the default Realm
    lazy var realm = try! Realm()
    
    let optionsKey = "optionsKey"
    
    //Each view (tab) loads its own set of items.
    //Load from viewDidLoad. Reload table from viewWillAppear
    var items: Results<Items>?
    var segment = Int()
    func loadItems(segment: Int) {
        items = self.realm.objects(Items.self).filter("segment = \(segment)").sorted(byKeyPath: "dateModified", ascending: true)
    }
    
//    //MARK: - Themeing
    
    open func setAppearance(segment: Int) {
        print("Setting theme")
        if getDarkModeStatus() {
            switch segment {
            case 0:
                Themes.switchTo(theme: .morningDark)
            case 1:
                Themes.switchTo(theme: .afternoonDark)
            case 2:
                Themes.switchTo(theme: .eveningDark)
            case 3:
                Themes.switchTo(theme: .nightDark)
            default:
                Themes.switchTo(theme: .monochromeDark)
            }
        } else {
            switch segment {
            case 0:
                Themes.switchTo(theme: .morningLight)
            case 1:
                Themes.switchTo(theme: .afternoonLight)
            case 2:
                Themes.switchTo(theme: .eveningLight)
            case 3:
                Themes.switchTo(theme: .nightLight)
            default:
                Themes.switchTo(theme: .monochromeDark)
            }
        }
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
    
    //MARK: - Smart Snooze
    //Run this first
    func runAutoSnooze() {
        print("runAutoSnooze")
        if getAutoSnoozeStatus() {
            print("autoSnooze true")
            var segmentsToSnooze: [Int] = []
            let currentSegment = getCurrentSegmentFromTime()
            print("currentSegment: \(currentSegment)")
            switch currentSegment {
            case 1:
                segmentsToSnooze = [0]
            case 2:
                segmentsToSnooze = [0,1]
            case 3:
                segmentsToSnooze = [0,1,2]
            default:
                segmentsToSnooze = [1,2,3]
            }
            
            segmentsToSnooze.forEach { (segment) in
                autoSnoozeMove(fromSegment: segment, toSegment: currentSegment)
            }
            
        }
    }
    //This does the work
    func autoSnoozeMove(fromSegment: Int, toSegment: Int) {
        print("running smartSnoozeMove from segment \(fromSegment) to \(toSegment)")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let items = realm.objects(Items.self).filter("segment = \(fromSegment) AND disableAutoSnooze = %@", false)
                items.forEach({ (item) in
                    if let itemDate = item.dateModified {
                        if itemDate < Date() {
                            do {
                                try realm.write {
                                    item.segment = toSegment
                                }
                            } catch {
                                print("failed to smartSnooze items")
                            }
                        }
                    }
                })
            }
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
    
    func getDateFromComponents(hour: Int, minute: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.calendar = Calendar.autoupdatingCurrent
        dateComponent.timeZone = TimeZone.autoupdatingCurrent
        dateComponent.hour = hour
        dateComponent.minute = minute
        return dateComponent.date!
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
            currentSegment = 3
        }
        return currentSegment
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
    
}
