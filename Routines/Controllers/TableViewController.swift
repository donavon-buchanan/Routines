//
//  TableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import SwiftMessages
import UIKit
import UserNotifications

class TableViewController: UITableViewController, UINavigationControllerDelegate, UITabBarControllerDelegate {
    @IBAction func unwindToTableViewController(segue _: UIStoryboardSegue) {}
    @IBOutlet var settingsBarButtonItem: UIBarButtonItem!
    @IBOutlet var addbarButtonItem: UIBarButtonItem!
    @IBOutlet var linesBarButtonItem: UIBarButtonItem!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!

    override var keyCommands: [UIKeyCommand]? {
        return [
            // TODO: Create a global array var that to add or remove these commands from within other functions so that they can be active based on UI state
            UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(addNewTask), discoverabilityTitle: "Add New Task"),
            UIKeyCommand(input: "o", modifierFlags: .alternate, action: #selector(openSettingsKeyCommand), discoverabilityTitle: "Open Settings"),
            UIKeyCommand(input: "e", modifierFlags: .init(arrayLiteral: .shift, .command), action: #selector(editKeyCommand), discoverabilityTitle: "Edit Current Tasks"),
            UIKeyCommand(input: "a", modifierFlags: .init(arrayLiteral: .shift, .command), action: #selector(showAllKeyCommand), discoverabilityTitle: "Show Entire Day"),
        ]
    }

    @objc func addNewTask() {
        performSegue(withIdentifier: "addSegue", sender: self)
    }

    @objc func openSettingsKeyCommand() {
        performSegue(withIdentifier: "optionsSegue", sender: self)
    }

    @objc func editKeyCommand() {
        if !tableView.isEditing {
            setEditing()
        } else {
            endEdit()
        }
    }

    @objc func showAllKeyCommand() {
        revealAllTasks()
    }

    let timeLabel = UILabel()

    @IBAction func editButtonPressed(_: UIBarButtonItem) {
        setEditing()
    }

    var linesBarButtonSelected = false

    fileprivate func revealAllTasks() {
        if linesBarButtonSelected {
            linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button")
            loadItemsForSegment(segment: segment)
            resetTableView()
        } else {
            title = AppStrings.allDay
            linesBarButtonSelected = true
            linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button-filled")
            loadAllItems()
            changeTabBar(hidden: true, animated: true)
        }
    }

    @IBAction func linesBarButtonPressed(_: UIBarButtonItem) {
        revealAllTasks()
    }

    func changeTabBar(hidden: Bool, animated: Bool) {
        guard let tabBar = self.tabBarController?.tabBar else { return }
        if tabBar.isHidden == hidden { return }
        let frame = tabBar.frame
        let offset = hidden ? frame.size.height : -frame.size.height
        let duration: TimeInterval = (animated ? 0.3 : 0.0)
        tabBar.isHidden = false
        setViewBackgroundGraphic(enabled: !hidden)
        extendedLayoutIncludesOpaqueBars = hidden

        UIView.animate(withDuration: duration, animations: {
            tabBar.frame = frame.offsetBy(dx: 0, dy: offset)
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offset)
            self.tableView.setNeedsDisplay()
            self.tableView.layoutIfNeeded()
        }, completion: { _ in
            tabBar.isHidden = hidden
        })
    }

    fileprivate func setEditing() {
        tableView.setEditing(true, animated: true)
        let clearButton = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(showClearAlert))
        navigationItem.leftBarButtonItems = [clearButton]
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedAlert))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEdit))
        navigationItem.rightBarButtonItems = [doneButton, trashButton]
    }

    @IBAction func longPressToEdit(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if let count = items?.count {
                if count > 0 {
                    if !tableView.isEditing {
                        setEditing()
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
        tableView.setEditing(false, animated: true)
        navigationItem.leftBarButtonItems = [settingsBarButtonItem, editBarButtonItem]
        navigationItem.rightBarButtonItems = [addbarButtonItem, linesBarButtonItem]
    }

    let realmDispatchQueueLabel: String = "background"

    // Footer view
    let footerView = UIView()

    override func viewDidLoad() {
        // print("Running viewDidLoad")
        super.viewDidLoad()
        observeOptions()

        tableView.allowsMultipleSelectionDuringEditing = true

        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil)

        tabBarController?.delegate = self
        navigationController?.delegate = self
        segment = tabBarController?.selectedIndex ?? 0

        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        setViewBackgroundGraphic(enabled: true)

        // Double check to save selected tab and avoid infrequent bug
        Options.setSelectedIndex(index: tabBarController!.selectedIndex)

        title = setNavTitle()
        // loadItems()
        if RoutinesPlus.getPurchasedStatus(), RoutinesPlus.getPurchasedProduct() != "" {
            // TODO: Need actual error handling here.
            verifyPurchase(product: RegisteredPurchase(rawValue: RoutinesPlus.getPurchasedProduct())!)
        }

        // prefetch prices
        if !RoutinesPlus.getPurchasedStatus() {
            getAllProductInfo(productIDs: [RegisteredPurchase.lifetime.rawValue, RegisteredPurchase.monthly.rawValue, RegisteredPurchase.yearly.rawValue])
        }

        tableView.estimatedRowHeight = 115
        tableView.rowHeight = UITableView.automaticDimension
    }

    @objc func appBecameActive() {
        // removeDeliveredNotifications()
        loadItems()
        updateBadge()
        // AppDelegate.removeOldNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // print("View Will Appear")
        // removeDeliveredNotifications()
    }

    override func viewWillDisappear(_: Bool) {
        printDebug("\(#function)")
        // removeColorBarViewFromCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // print("viewDidAppear")
        TableViewController.setAppearance(segment: segment)
        loadItems()
    }

    func setTimeInTitle(timeString _: String) {
//        timeLabel.text = timeString
//        timeLabel.theme_textColor = GlobalPicker.barTextColor
//        navigationItem.titleView = timeLabel
//
//        // need to re-layout title since it can be changed
//        navigationItem.titleView?.setNeedsUpdateConstraints()
    }

    func setNavTitle() -> String {
        // print("Setting table title")
        switch segment {
        case 1:
            return "Afternoon"
        case 2:
            return "Evening"
        case 3:
            return "Night"
        default:
            return "Morning"
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect _: UIViewController) {
        Options.setSelectedIndex(index: tabBarController.selectedIndex)
    }

//
//    func getSelectedTab() -> Int {
//        var index = Int()
//
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                    index = options.selectedIndex
//                }
//            }
//        }
//        return index
//    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell
        let segment = items?[indexPath.row].segment
        let cellTitle: String = (items?[indexPath.row].title)!
        var cellSubtitle: String? {
            if let subtitle = self.items?[indexPath.row].notes {
                if subtitle.count > 0 {
                    return subtitle
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        var repeatLabel: String {
            if (items?[indexPath.row].repeats)! {
                return "Repeats Daily"
            } else {
                return ""
            }
        }

        var segmentColor: UIColor {
            switch segment {
            case 0:
                return UIColor(rgba: "#f47645", defaultColor: .red)
            case 1:
                return UIColor(rgba: "#26baee", defaultColor: .red)
            case 2:
                return UIColor(rgba: "#62a388", defaultColor: .red)
            case 3:
                return UIColor(rgba: "#645be7", defaultColor: .red)
            default:
                return .clear
            }
        }

        if linesBarButtonSelected {
            cell.configColorBar(segment: segment)
        } else {
            cell.configColorBar(segment: nil)
        }

        cell.repeatLabel?.text = repeatLabel
        cell.repeatLabel?.textColor = segmentColor

        cell.cellTitleLabel?.text = cellTitle
        cell.cellSubtitleLabel?.text = cellSubtitle

        return cell
    }

//    func addColorBarsViewToCells() {
//        var barView = UIView()
//        barView.tag = 2
//
//        tableView.indexPathsForVisibleRows?.forEach { indexPath in
//            if let cell = self.tableView.cellForRow(at: indexPath) {
//                var barView = UIView()
//                barView.tag = 2
//
//                var segmentColor: UIColor {
//                    switch self.items?[indexPath.row].segment {
//                    case 0:
//                        return UIColor(rgba: "#f47645", defaultColor: .red)
//                    case 1:
//                        return UIColor(rgba: "#26baee", defaultColor: .red)
//                    case 2:
//                        return UIColor(rgba: "#62a388", defaultColor: .red)
//                    case 3:
//                        return UIColor(rgba: "#645be7", defaultColor: .red)
//                    default:
//                        return .clear
//                    }
//                }
//
//                barView.frame = CGRect(x: 0, y: 0, width: 6, height: cell.frame.height)
//                barView.backgroundColor = segmentColor
//                cell.contentView.addSubview(barView)
//            }
//        }
//    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let completeAction = UITableViewRowAction(style: .destructive, title: "Complete") { _, indexPath in
            self.completeItemAtIndex(at: indexPath)
        }

        let snoozeAction = UITableViewRowAction(style: .default, title: "Snooze") { _, indexPath in
            self.snoozeItem(indexPath: indexPath)
        }

        completeAction.backgroundColor = UIColor(red: 0.38, green: 0.70, blue: 0.22, alpha: 1.00)
        snoozeAction.backgroundColor = UIColor.orange
        return [completeAction, snoozeAction]
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.completeItemAtIndex(at: indexPath)
            completion(true)
        }
        let snoozeAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.snoozeItem(indexPath: indexPath)
            if !self.linesBarButtonSelected {
                completion(true)
            } else {
                completion(false)
            }
        }
        let nextSectionAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.moveItemToNext(indexPath: indexPath)
            if !self.linesBarButtonSelected {
                completion(true)
            } else {
                completion(false)
            }
        }
        // TODO: Image is not centered
        completeAction.image = UIImage(imageLiteralResourceName: "checkmark")
        completeAction.backgroundColor = UIColor(red: 0.30, green: 0.43, blue: 1.00, alpha: 1.00)
        snoozeAction.backgroundColor = .orange
        snoozeAction.image = UIImage(imageLiteralResourceName: "snooze")
        nextSectionAction.backgroundColor = UIColor(rgba: "#26baee", defaultColor: .blue)
        nextSectionAction.image = UIImage(imageLiteralResourceName: "arrow-right")
        let actions = UISwipeActionsConfiguration(actions: [completeAction, snoozeAction, nextSectionAction])
        return actions
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            completion(self.deleteAlert(indexPath))
        }
        deleteAction.image = UIImage(imageLiteralResourceName: "trash-icon")
        let actions = UISwipeActionsConfiguration(actions: [deleteAction])
        return actions
    }

//    @available(iOS 11.0, *)
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let ignoreAction = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
//            self.snoozeItem(indexPath: indexPath)
//            self.tableView.deleteRows(at: [indexPath], with: .right)
//            completion(true)
//        }
//        ignoreAction.backgroundColor = .orange
//        let anchorImageView = UIImageView()
//        anchorImageView.image = UIImage(imageLiteralResourceName: "snoozeStrike").withRenderingMode(.alwaysTemplate)
//        anchorImageView.theme_tintColor = GlobalPicker.cellTextColors
//        ignoreAction.image = anchorImageView.image
//        let backgroundColorView = UIView()
//        backgroundColorView.theme_backgroundColor = GlobalPicker.barTextColor
//        ignoreAction.backgroundColor = backgroundColorView.backgroundColor
//        let actions = UISwipeActionsConfiguration(actions: [ignoreAction])
//        return actions
//    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .delete) {
//            softDeleteAtIndex(at: indexPath)
//            self.tableView.deleteRows(at: [indexPath], with: .left)
//        }
//    }

//    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let notes = items?[indexPath.row].notes {
//            if notes.count > 0 {
//                return UITableView.automaticDimension
//            } else {
//                return 80
//            }
//        } else {
//            return 80
//        }
//    }

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

    override func shouldPerformSegue(withIdentifier identifier: String, sender _: Any?) -> Bool {
        if identifier == "editSegue" {
            if tableView.isEditing {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt _: IndexPath) {
        // print("Selected index paths: \(String(describing: tableView.indexPathsForSelectedRows))")
    }

    @objc func showClearAlert() {
        showAlert(title: "Are you sure?", body: "This will mark all the tasks shown as completed. Repeating tasks will still appear again tomorrow.")
    }

    @objc private func clearAll() {
        items?.forEach { item in
            // TODO: Might be better to just grab a whole filtered list and then delete from there
            item.completeItem()
            // updateBadge()
        }
        endEdit()
        resetTableView()
        changeTabBar(hidden: false, animated: true)
    }

    // TODO: Do this for completing items too
    @objc func deleteSelectedRows() {
        var itemCount: Int {
            if let items = self.items {
                return items.count
            } else {
                return 0
            }
        }
        var selectedCount: Int {
            if let selectedPaths = tableView.indexPathsForSelectedRows {
                return selectedPaths.count
            } else {
                return 0
            }
        }

        if selectedCount != 0 {
            if let indexPaths = self.tableView.indexPathsForSelectedRows {
                var itemArray: [Items] = []
                indexPaths.forEach { indexPath in
                    // The index paths are static during enumeration, but the item indexes are not
                    // Add them to an array first, delete only what's in the array, and then update the table UI
                    if let itemAtIndex = self.items?[indexPath.row] {
                        itemArray.append(itemAtIndex)
                    }
                }

                itemArray.forEach { item in
                    item.softDelete()
                }
            }
        } else if selectedCount == 0, itemCount != 0 {
            items?.forEach { item in
                item.softDelete()
            }
            endEdit()
            resetTableView()
            changeTabBar(hidden: false, animated: true)
        }

        updateBadge()
    }

//    //Delay func
//    func delay(_ delay:Double, closure:@escaping ()->()) {
//        DispatchQueue.main.asyncAfter(
//            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
//    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func resetTableView() {
        // Reset the view just before segue
        if linesBarButtonSelected {
            title = setNavTitle()
            DispatchQueue.main.async {
                autoreleasepool {
                    self.linesBarButtonSelected = false
                    self.linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button")
                    self.loadItemsForSegment(segment: self.segment)
                    self.changeTabBar(hidden: false, animated: true)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "addSegue" {
            let navVC = segue.destination as! UINavigationController
            let destination = navVC.topViewController as! AddTableViewController
            // set segment based on current tab
            guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
            destination.editingSegment = selectedTab
            // destination.segue = segue
            resetTableView()
        }

        if segue.identifier == "editSegue" {
            let navVC = segue.destination as! UINavigationController
            let destination = navVC.topViewController as! AddTableViewController

            // pass in current item
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.item = items?[indexPath.row]
                // destination.segue = segue
            }
        }

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    // MARK: - Model Manipulation Methods

//    func loadData() -> Results<Items> {
//        return realm.objects(Items.self)
//    }

    // Filter items to relevant segment and return those items
//    func loadItems(segment: Int) -> Results<Items> {
//        guard let filteredItems = items?.filter("segment = \(segment)") else { fatalError() }
//        // print("loadItems run")
//        //self.tableView.reloadData()
//        return filteredItems
//    }

    // Override empty delete func from super
    func softDeleteAtIndex(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            item.softDelete()
            updateBadge()
        }
    }

    func completeItemAtIndex(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            item.completeItem()
            updateBadge()
        }
    }

    func snoozeItem(indexPath: IndexPath) {
        guard let item = items?[indexPath.row] else { return }
        item.snooze()
    }

    func moveItemToNext(indexPath: IndexPath) {
        guard let item = items?[indexPath.row] else { return }
        item.moveToNextSegment()
    }

//    func setItemToIgnore(indexPath: IndexPath, ignore: Bool) {
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                do {
//                    try! realm.write {
//                        if let item = self.items?[indexPath.row] {
//                            item.disableAutoSnooze = ignore
//                        }
//                    }
//                }
//            }
//        }
//        OptionsTableViewController().refreshNotifications()
//    }

    // TODO: Animated reload would be nice
//    func reloadTableView() {
//        //tableView.reloadData()
//    }

    // Set background graphic
    func setViewBackgroundGraphic(enabled: Bool) {
        if enabled {
            let backgroundImageView = UIImageView()
            let backgroundImage = UIImage(imageLiteralResourceName: "inlay")

            backgroundImageView.image = backgroundImage
            backgroundImageView.contentMode = .scaleAspectFit

            tableView.backgroundView = backgroundImageView
//            view.setNeedsDisplay()
//            view.layoutIfNeeded()
            UIView.transition(with: view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
        } else {
            tableView.backgroundView = UIView()
            UIView.transition(with: view, duration: 0.0, options: .transitionCrossDissolve, animations: nil)
        }
    }

    // Update tab bar badge counts
    func updateBadge() {
        DispatchQueue.main.async {
            autoreleasepool {
                if let tabs = self.tabBarController?.tabBar.items {
                    for tab in 0 ..< tabs.count {
                        let count = self.getCountForTab(tab)
                        // print("Count for tab \(tab) is \(count)")
                        if count > 0 {
                            tabs[tab].badgeValue = "\(count)"
                        } else {
                            tabs[tab].badgeValue = nil
                        }
                    }
                }
            }
        }
    }

    func getCountForTab(_ tab: Int) -> Int {
        let realm = try! Realm()
        let items = realm.objects(Items.self).filter("segment = %@ AND dateModified < %@ AND isDeleted = \(false) AND completeUntil < %@", tab, Date(), Date().endOfDay)
        var badgeCount = 0
        items.forEach { item in
            if item.firstTriggerDate(segment: item.segment) < Date() {
                badgeCount += 1
            }
        }
        return badgeCount
    }

    // MARK: - Manage Notifications

//    let center = UNUserNotificationCenter.current()
//
//    func removeNotification(uuidString: [String]) {
//        // print("Removing Notifications")
//        let center = UNUserNotificationCenter.current()
//        center.removePendingNotificationRequests(withIdentifiers: uuidString)
//    }
//
//    func removeDeliveredNotifications() {
//        let center = UNUserNotificationCenter.current()
//        center.getDeliveredNotifications { notifications in
//            for notification in notifications {
//                // TODO: If repeats, remove and then add again
//                // Get the ID and then get the properties of the specific object
//                // Need to get all the same notification functions used in other views to be able to create
//                center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
//            }
//        }
//    }

    // Notification Settings Screen
//    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
//        // print("Opening settings")
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let optionsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsView") as! OptionsTableViewController
//        self.navigationController?.pushViewController(optionsViewController, animated: true)
//    }

    // MARK: - Realm

    var items: Results<Items>?

    var segment = Int()

    func loadItemsForSegment(segment: Int) {
        #if DEBUG
            print("loading items for segment \(segment)")
            print("end of today is: \(Date().endOfDay)")
        #endif
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                self.items = realm.objects(Items.self).filter("segment = \(segment) AND isDeleted = \(false) AND completeUntil < %@", Date().endOfDay).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false)
            }
        }
        realmSync()
    }

    func loadAllItems() {
        #if DEBUG
            print("loading all items")
            print("end of today is: \(Date().endOfDay)")
        #endif
        // Sort by segment to put in order of the day
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                self.items = realm.objects(Items.self).filter("isDeleted = \(false) AND completeUntil < %@", Date().endOfDay).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
            }
        }
        realmSync()
    }

    func loadItems() {
        if linesBarButtonSelected {
            loadAllItems()
        } else {
            loadItemsForSegment(segment: segment)
        }
    }

//    private func deleteItem(item: Items) {
//        item.softDelete() // item.deleteItem()
//        updateBadge()
//    }
//
    var notificationToken: NotificationToken?

    func realmSync() {
        // TODO: https://realm.io/docs/swift/latest/#interface-driven-writes
        // Observe Results Notifications
        notificationToken = items?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                printDebug("Initial load")
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case let .update(_, deletions, insertions, modifications):
                printDebug("update detected")
                // Query results have changed, so apply them to the UITableView
                tableView.performBatchUpdates({
                    tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                         with: .right)
                    tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
                                         with: .fade)
                }, completion: nil)
            case let .error(error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }

    deinit {
        printDebug("\(#function) called. Tokens invalidated")
        notificationToken?.invalidate()
        debugOptionsToken?.invalidate()
        optionsToken?.invalidate()
    }

    // var options: Options = Options()
    var debugOptionsToken: NotificationToken?
    var optionsToken: NotificationToken?

    // Need to observe all options even though there will really only be one object because sometimes that object may need to be deleted
    func observeOptions() {
        let realm = try! Realm()
        let optionsList = realm.objects(Options.self)
        optionsToken = optionsList.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
            case .initial:
                printDebug("Initial load for Options. But don't do anything yet")
            //                TableViewController.setAppearance(segment: self.tabBarController?.selectedIndex ?? 0)
            //                AppDelegate.setAutomaticDarkModeTimer()
            case .update:
                guard realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) != nil else { return }
                DispatchQueue.main.async {
                    TableViewController.setAppearance(segment: self.tabBarController?.selectedIndex ?? 0)
                    AppDelegate.setAutomaticDarkModeTimer()
                }
            case let .error(error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }

    // MARK: - Themeing

    static func setAppearance(segment: Int) {
        printDebug("Dark mode is: \(Options.getDarkModeStatus())")
        if Options.getDarkModeStatus() {
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

//    public func getDarkModeStatus() -> Bool {
//        var darkMode = false
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                do {
//                    let realm = try! Realm()
//                    if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                        darkMode = options.darkMode
//                    }
//                }
//            }
//        }
//        return darkMode
//    }

//    func getOptionHour(segment: Int) -> Int {
//        var hour = Int()
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                    switch segment {
//                    case 1:
//                        hour = options.afternoonHour
//                    case 2:
//                        hour = options.eveningHour
//                    case 3:
//                        hour = options.nightHour
//                    default:
//                        hour = options.morningHour
//                    }
//                }
//            }
//        }
//        return hour
//    }

//    func getOptionMinute(segment: Int) -> Int {
//        var minute = Int()
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)
//                switch segment {
//                case 1:
//                    minute = (options?.afternoonMinute)!
//                case 2:
//                    minute = (options?.eveningMinute)!
//                case 3:
//                    minute = (options?.nightMinute)!
//                default:
//                    minute = (options?.morningMinute)!
//                }
//            }
//        }
//
//        return minute
//    }

    // MARK: - Banners

//    func showBanner(title: String?) {
//        SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: .normal)
//        SwiftMessages.pauseBetweenMessages = 0
//        SwiftMessages.hideAll()
//        SwiftMessages.show { () -> UIView in
//            let banner = MessageView.viewFromNib(layout: .statusLine)
//            banner.configureTheme(.success)
//            banner.configureContent(title: "", body: title ?? "Task Snoozed")
//            return banner
//        }
//    }

    func deleteAlert(_ indexPath: IndexPath) -> Bool {
        var completion = false
        let alertController = UIAlertController(title: "Are you sure?", message: "This will permanently delete this task.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.softDeleteAtIndex(at: indexPath)
            completion = true
        }))
        present(alertController, animated: true, completion: nil)
        return completion
    }

    @objc func deleteSelectedAlert() {
        var itemCount: Int {
            if let items = self.items {
                return items.count
            } else {
                return 0
            }
        }
        var selectedCount: Int {
            if let selectedPaths = tableView.indexPathsForSelectedRows {
                return selectedPaths.count
            } else {
                return 0
            }
        }

        let alertController = UIAlertController(title: "Are you sure?", message: "This will permanently delete these tasks.", preferredStyle: .alert)

        if selectedCount != 0 {
            if selectedCount == 1 {
                alertController.message = "This will permanently delete the selected task."
            } else {
                alertController.message = "This will permanently delete \(selectedCount) selected tasks."
            }
        } else if selectedCount == 0, itemCount != 0 {
            if itemCount == 1 {
                alertController.message = "This will permanently delete the task shown."
            } else {
                alertController.message = "This will permanently delete all \(itemCount) tasks shown."
            }
        } else {
            return
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteSelectedRows()
        }))
        present(alertController, animated: true, completion: nil)
    }

    func showAlert(title: String, body: String) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .center
        config.duration = .forever

        let alert = MessageView.viewFromNib(layout: .cardView)
        let icon = "⁉️"
        alert.configureTheme(.info, iconStyle: .default)
        alert.configureContent(title: title, body: body, iconText: icon)
        alert.titleLabel?.textColor = .black
        alert.bodyLabel?.textColor = .black

        // alert.button?.backgroundColor = .red
        alert.button?.setTitleColor(.white, for: .normal)
        alert.button?.setTitle("Do it!", for: .normal)
        alert.button?.addTarget(self, action: #selector(clearAll), for: .touchUpInside)

        alert.buttonTapHandler = { _ in SwiftMessages.hide() }

        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        alert.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (alert.backgroundView as? CornerRoundingView)?.cornerRadius = 10

        if Options.getDarkModeStatus() {
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.dimModeAccessibilityLabel = "Dismiss Warning"
        } else {
            config.dimMode = .blur(style: .regular, alpha: 1, interactive: true)
            config.dimModeAccessibilityLabel = "Dismiss Warning"
        }

        SwiftMessages.show(config: config, view: alert)
    }
}
