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

class TableViewController: SwipeTableViewController, UINavigationControllerDelegate, UITabBarControllerDelegate, UNUserNotificationCenterDelegate {
    
    @IBAction func unwindToTableViewController(segue:UIStoryboardSegue){}
    
    let realmDispatchQueueLabel: String = "background"
    
    //let optionsKey = "optionsKey"
    
    //let segmentStringArray: [String] = ["Morning", "Afternoon", "Evening", "Night", "All Day"]
    
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
    //var selectedTab = 0

    override func viewDidLoad() {
        print("Running viewDidLoad")
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        self.navigationController?.delegate = self
        self.segment = self.tabBarController?.selectedIndex ?? 0
        //TODO: Fade cells into top nav bar
        //self.tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        
        footerView.backgroundColor = .clear
        self.tableView.tableFooterView = footerView
        
        setViewBackgroundGraphic()
        
        loadItems(segment: self.segment)
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        
//        guard let fromView = tabBarController.selectedViewController?.view, let toView = viewController.view else {
//            return false // Make sure you want this as false
//        }
//        
//        if fromView != toView {
//            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
//        }
//        
//        return true
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear")
        self.tabBarController?.tabBar.isHidden = false
        reloadTableView()
        updateBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear \n")
        changeSegment(segment: passedSegment)
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
        super.updateModel(at: indexPath)
        let realm = try! Realm()
        do {
            try! realm.write {
                let item = items?[indexPath.row]
                self.removeNotification(uuidString: [item!.uuidString])
                realm.delete(item!)
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
                print("Count for tab \(tab) is \(count)")
                if count > 0 {
                    tabs[tab].badgeValue = "\(count)"
                } else {
                    tabs[tab].badgeValue = nil
                }
            }
        }
    }
    
    func getSegmentCount(segment: Int) -> Int {
        let realm = try! Realm()
        return realm.objects(Items.self).filter("segment = \(segment)").count
    }
    
    //MARK: - Manage Notifications
    public func removeNotification(uuidString: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidString)
    }
    
    
    //MARK: - Realm
    
    // Get the default Realm
    let realm = try! Realm()
    
    //Each view (tab) loads its own set of items.
    //Load from viewDidLoad. Reload table from viewWillAppear
    var items: Results<Items>?
    var segment = Int()
    func loadItems(segment: Int) {
        items = self.realm.objects(Items.self).filter("segment = \(segment)")
    }
    
//    //MARK: - Themeing
//    func setMorningColors() {
//        
//    }
//    
//    func setAfternoonColors() {
//        
//    }
//    
//    func setEveningColors() {
//        
//    }
//    
//    func setDarkMode() {
//        
//    }
    
}
