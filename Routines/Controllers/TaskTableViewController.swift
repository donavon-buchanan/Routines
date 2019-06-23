//
//  TaskTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import SwiftMessages
import SwiftTheme
import UIKit
import UserNotifications

class TaskTableViewController: UITableViewController, UINavigationControllerDelegate, UITabBarControllerDelegate {
    @IBAction func unwindToTableViewController(segue _: UIStoryboardSegue) {}
    @IBOutlet var settingsBarButtonItem: UIBarButtonItem!
    @IBOutlet var addbarButtonItem: UIBarButtonItem!
    @IBOutlet var linesBarButtonItem: UIBarButtonItem!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!

//    var shouldShowHiddenTasksMessage = false

    override var keyCommands: [UIKeyCommand]? {
        return [
            // TODO: Create a global array var that to add or remove these commands from within other functions so that they can be active based on UI state
            UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(addNewTask), discoverabilityTitle: "Add New Task"),
            UIKeyCommand(input: "o", modifierFlags: .alternate, action: #selector(openSettings), discoverabilityTitle: "Open Settings"),
            UIKeyCommand(input: "e", modifierFlags: .init(arrayLiteral: .shift, .command), action: #selector(editKeyCommand), discoverabilityTitle: "Edit List"),
            UIKeyCommand(input: "a", modifierFlags: .init(arrayLiteral: .shift, .command), action: #selector(showAllKeyCommand), discoverabilityTitle: "Show Entire Day"),
        ]
    }

    @objc func addNewTask() {
        performSegue(withIdentifier: "addSegue", sender: self)
    }

    @objc func openSettings() {
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
            // Already being called from resetTableView
            // loadItemsForSegment(segment: segment)
            resetTableView()
        } else {
            title = AppStrings.allDay.localizedCapitalized
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
        //        setViewBackgroundGraphic(enabled: !hidden)
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

    fileprivate func fetchIAPInfo() {
        // prefetch prices
        if !RoutinesPlus.getPurchasedStatus() {
            getAllProductInfo(productIDs: [RegisteredPurchase.lifetime.rawValue, RegisteredPurchase.monthly.rawValue, RegisteredPurchase.yearly.rawValue])
        }
    }

    override func viewDidLoad() {
        debugPrint(#function + " start")
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil)

        // This convoluted mess is needed because the tab bar controller returns some inane int value during restoration because viewDidLoad is called for all four tabs at once.
        if let tabBarController = tabBarController {
            if tabBarController.selectedIndex < 4 {
                printDebug("tabBarController index < 4, setting to \(tabBarController.selectedIndex)")
                if segment == nil {
                    segment = tabBarController.selectedIndex
                }
            }
        } else {
            printDebug("tabBarController is nil. Setting segment to 0")
            if segment == nil {
                segment = 0
            }
        }
        tableView.allowsMultipleSelectionDuringEditing = true

        tabBarController?.delegate = self
        navigationController?.delegate = self

        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        //        setViewBackgroundGraphic(enabled: true)

        // Double check to save selected tab and avoid infrequent bug
        //        Options.setSelectedIndex(index: tabBarController!.selectedIndex)

        //title = returnTitle(forSegment: tabBarController?.selectedIndex ?? 0)

        tableView.estimatedRowHeight = 115
        tableView.rowHeight = UITableView.automaticDimension

        printDebug(#function + " end")
    }

    @objc func appBecameActive() {
        debugPrint(#function + " start")
        observeOptions()
        observeItems()
        // View loading funcs aren't always called when the app transitions from background to active
        // So this is to ensure that the UI refreshes
        Options.automaticDarkModeCheck()
        TaskTableViewController.setAppearance(forSegment: Options.getSelectedIndex())

        printDebug(#function + " end")
    }

    override func applicationFinishedRestoringState() {
        /*
         Because multiple views use this class, I needed a way to set the "segment" property independently
          This function is called in order of the tab heirarchy. Since that's known,
          we can just iterate through and get the first child view of each tab's navigation controller
          because we also know that first child view will always be the table view controller for this class.
          Once we have that, we set the segment to match the index of the enumeration of controllers.
          It's a little bit of a hack, yes. But the app heirachy is static enough that it works. It's not ideal,
          but imo, it's a lot better than creating a bunch of nearly identical views and classes with inheritance complications
         */
        if let controllers = self.tabBarController?.viewControllers {
            let navigationControllers = controllers.enumerated().map { ($0, $1) }
            navigationControllers.forEach { index, navigationViewController in
                let tableViewController = navigationViewController.children[0] as! TaskTableViewController
                tableViewController.segment = index
            }
        }
        // Avoids flashing screen glitch
        // TODO: Restoration is loading all the views at once
        printDebug("View loaded? - \(isViewLoaded)")
        TaskTableViewController.setAppearance(forSegment: Options.getSelectedIndex())
    }

    override func viewWillAppear(_: Bool) {
        debugPrint(#function + " start")

        loadItemsForSegment(segment: segment!)
        TaskTableViewController.setAppearance(forSegment: segment!)

        title = returnTitle(forSegment: segment!)
        debugPrint(#function + " end")
    }

    override func viewWillDisappear(_: Bool) {
        printDebug("\(#function)")
    }

    override func viewDidAppear(_: Bool) {
        debugPrint(#function + " start")

        if RoutinesPlus.getPurchasedStatus(), RoutinesPlus.getPurchasedProduct() != "", RoutinesPlus.getPurchasedProduct() != RegisteredPurchase.lifetime.rawValue, Date() >= RoutinesPlus.getExpiryDate() {
            debugPrint("Routines Plus Purchased: \(RoutinesPlus.getPurchasedStatus())")
            debugPrint("Routines Plus Product: \(RoutinesPlus.getPurchasedProduct())")
            verifyReceipt()
        } else {
            debugPrint("No need to verify yet. Will check on \(RoutinesPlus.getExpiryDate())")
            debugPrint("Routines Plus Purchased: \(RoutinesPlus.getPurchasedStatus())")
            debugPrint("Routines Plus Product: \(RoutinesPlus.getPurchasedProduct())")
        }

        fetchIAPInfo()

        // Kind of a band aid for orphaned notifications.
        // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        AppDelegate.removeOldNotifications()

//        if shouldShowHiddenTasksMessage {
//            showHiddenTasksMessage()
//            shouldShowHiddenTasksMessage = false
//        }

        debugPrint(#function + " end")
    }

//    func showHiddenTasksMessage() {
//        if !UserDefaults.standard.bool(forKey: "hiddenTasksMessageShown"), !RoutinesPlus.getShowUpcomingTasks() {
//            printDebug("Showing hidden task message")
//            let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
//                self.openSettings()
//            }
//            showStandardAlert(title: "Don't see your new task?", body: "Don't worry, it's there. Because your \(returnTitle(forSegment: segment ?? Options.getSelectedIndex())) time has already happened, your task has been created for tomorrow. To see what's happening tomorrow, you can enable Show Upcoming Tasks from the settings.", action: settingsAction)
//            UserDefaults.standard.set(true, forKey: "hiddenTasksMessageShown")
//        } else {
//            shouldShowHiddenTasksMessage = false
//        }
//    }

    func returnTitle(forSegment segment: Int) -> String {
        printDebug(#function + " segment: \(segment)")
        switch segment {
        case 0:
            return AppStrings.timePeriod.morning.rawValue.localizedCapitalized
        case 1:
            return AppStrings.timePeriod.afternoon.rawValue.localizedCapitalized
        case 2:
            return AppStrings.timePeriod.evening.rawValue.localizedCapitalized
        default:
            return AppStrings.timePeriod.night.rawValue.localizedCapitalized
        }
    }

    //
    //    func setTabBarTitles() {
    //        if let tabBarItems = self.tabBarController?.tabBar.items {
    //            let items = tabBarItems.enumerated().map { ($0, $1) }
    //            items.forEach { index, item in
    //                item.title = returnTitle(forSegment: index)
    //            }
    //        }
    //    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect _: UIViewController) {
        Options.setSelectedIndex(index: tabBarController.selectedIndex)
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell

        // Realm occasionally throws an error here. Use guard to return early if the item no-longer exist.
        guard let item = items?[indexPath.row] else { return cell }

        let segment = item.segment
        let cellTitle: String = item.title!
        var cellSubtitle: String? {
            if let subtitle = item.notes {
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
            if item.completeUntil < Date().endOfDay {
                if item.repeats {
                    return "Repeats Daily"
                } else {
                    return ""
                }
            } else {
                if item.repeats {
                    return "Tomorrow - Repeats Daily"
                } else {
                    return "Tomorrow"
                }
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

        if item.completeUntil > Date().endOfDay {
            cell.cellTitleLabel.textColor = .lightGray
            cell.cellSubtitleLabel.textColor = .lightGray
            cell.repeatLabel.textColor = .lightGray
        }

        return cell
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = items?[indexPath.row] else { return nil }
        let itemSegment = item.segment
        var nextColor: UIColor {
            switch itemSegment {
            case 1:
                return UIColor(rgba: "#62a388", defaultColor: .blue)
            case 2:
                return UIColor(rgba: "#645be7", defaultColor: .blue)
            case 3:
                return UIColor(rgba: "#f47645", defaultColor: .blue)
            default:
                return UIColor(rgba: "#26baee", defaultColor: .blue)
            }
        }

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
            printDebug("\(#function) - indexPath: \(String(describing: indexPath))")
            self.moveItemToNext(indexPath: indexPath)
            if !self.linesBarButtonSelected {
                completion(true)
            } else {
                completion(false)
            }
        }

        completeAction.image = UIImage(imageLiteralResourceName: "checkmark")
        completeAction.backgroundColor = GlobalPicker.primaryColor
        snoozeAction.backgroundColor = GlobalPicker.snoozeColor
        snoozeAction.image = UIImage(imageLiteralResourceName: "snooze")
        nextSectionAction.backgroundColor = nextColor
        nextSectionAction.image = UIImage(imageLiteralResourceName: "arrow-right")

        var arrayOfActions: [UIContextualAction] = []
        if item.completeUntil < Date().endOfDay {
            arrayOfActions = [completeAction, snoozeAction, nextSectionAction]
        } else {
            arrayOfActions = [nextSectionAction]
        }

        let actions = UISwipeActionsConfiguration(actions: arrayOfActions)
        return actions
    }

    override func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            completion(self.deleteAlert(indexPath))
        }
        deleteAction.image = UIImage(imageLiteralResourceName: "trash-icon")
        let actions = UISwipeActionsConfiguration(actions: [deleteAction])
        return actions
    }

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

    @objc func showClearAlert() {
        showAlert(title: "Are you sure?", body: "This will mark all the tasks shown as completed. Repeating tasks will still appear again tomorrow.")
    }

    @objc private func clearAll() {
        var itemAray: [Items] = []

        if let items = items {
            itemAray.append(contentsOf: items)
        }

        Items.batchComplete(itemArray: itemAray)

        endEdit()
        // resetTableView()
        // changeTabBar(hidden: false, animated: true)
    }

    // TODO: Do this for completing items too
    @objc func deleteSelectedRows() {
        var itemCount: Int {
            if let items = items {
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

        var itemsToDelete: [Items] = []

        if selectedCount != 0 {
            if let indexPaths = self.tableView.indexPathsForSelectedRows {
                var itemArray: [Items] = []
                indexPaths.forEach { indexPath in
                    // The index paths are static during enumeration, but the item indexes are not
                    // Add them to an array first, delete only what's in the array, and then update the table UI
                    if let itemAtIndex = items?[indexPath.row] {
                        itemArray.append(itemAtIndex)
                    }
                }

                itemArray.forEach { item in
                    itemsToDelete.append(item)
                }
                Items.batchSoftDelete(itemArray: itemsToDelete)
            }
        } else if selectedCount == 0, itemCount != 0 {
            items?.forEach { item in
                itemsToDelete.append(item)
            }
            Items.batchSoftDelete(itemArray: itemsToDelete)
            endEdit()
            resetTableView()
            changeTabBar(hidden: false, animated: true)
        }

        //        updateBadge()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func resetTableView() {
        // Reset the view just before segue
        if linesBarButtonSelected {
            title = returnTitle(forSegment: segment ?? 0)
            DispatchQueue.main.async {
                autoreleasepool {
                    self.linesBarButtonSelected = false
                    self.linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button")
                    self.loadItemsForSegment(segment: self.segment ?? 0)
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

            resetTableView()
        }

        if segue.identifier == "editSegue" {
            let navVC = segue.destination as! UINavigationController
            let destination = navVC.topViewController as! AddTableViewController

            // pass in current item
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.item = items?[indexPath.row]
            }
        }

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    // MARK: - Model Manipulation Methods

    // Override empty delete func from super
    func softDeleteAtIndex(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            item.softDelete()
            //            updateBadge()
        }
    }

    func completeItemAtIndex(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            item.completeItem()
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

    // Set background graphic
    //    func setViewBackgroundGraphic(enabled: Bool) {
    //        if enabled {
    //            let backgroundImageView = UIImageView()
    //            let backgroundImage = UIImage(imageLiteralResourceName: "inlay")
    //
    //            backgroundImageView.image = backgroundImage
    //            backgroundImageView.contentMode = .scaleAspectFit
    //
    //            tableView.backgroundView = backgroundImageView
    ////            view.setNeedsDisplay()
    ////            view.layoutIfNeeded()
    //            UIView.transition(with: view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
    //        } else {
    //            tableView.backgroundView = UIView()
    //            UIView.transition(with: view, duration: 0.0, options: .transitionCrossDissolve, animations: nil)
    //        }
    //    }

    // Update tab bar badge counts
    //    func updateBadge() {
    //        DispatchQueue.main.async {
    //            autoreleasepool {
    //                if let tabs = self.tabBarController?.tabBar.items {
    //                    for tab in 0 ..< tabs.count {
    //                        let count = self.getCountForTab(tab)
    //                        // print("Count for tab \(tab) is \(count)")
    //                        if count > 0 {
    //                            tabs[tab].badgeValue = "\(count)"
    //                        } else {
    //                            tabs[tab].badgeValue = nil
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }

    // Don't need this if we're not doing a badge for the tabs
    //    func getCountForTab(_ tab: Int) -> Int {
    //        let realm = try! Realm()
    //        let items = realm.objects(Items.self).filter("segment = %@ AND dateModified < %@ AND isDeleted = \(false) AND completeUntil < %@", tab, Date(), Date().endOfDay)
    //        var badgeCount = 0
    //        items.forEach { item in
    //            if item.firstTriggerDate(segment: item.segment) < Date() {
    //                badgeCount += 1
    //            }
    //        }
    //        return badgeCount
    //    }

    // MARK: - Manage Notifications

    // MARK: - Realm

    var items: Results<Items>?

    var segment: Int?

    func loadItemsForSegment(segment: Int) {
        printDebug("loading items for segment \(segment)")
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if RoutinesPlus.getShowUpcomingTasks() {
                    self.items = realm.objects(Items.self).filter("segment = \(segment) AND isDeleted = \(false)").sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "completeUntil", ascending: true)
                } else {
                    self.items = realm.objects(Items.self).filter("segment = \(segment) AND isDeleted = \(false) AND completeUntil < %@", Date().endOfDay).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false)
                }
            }
        }
        // For now it has to be like this
        // Otherwise, items get potentially loaded into cells they should or that don't exist and crash
        observeItems()
    }

    func loadAllItems() {
        printDebug("loading all items")
        // Sort by segment to put in order of the day
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if RoutinesPlus.getShowUpcomingTasks() {
                    self.items = realm.objects(Items.self).filter("isDeleted = \(false)").sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true).sorted(byKeyPath: "completeUntil", ascending: true)
                } else {
                    self.items = realm.objects(Items.self).filter("isDeleted = \(false) AND completeUntil < %@", Date().endOfDay).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "segment", ascending: true)
                }
            }
        }
        // For now it has to be like this
        // Otherwise, items get potentially loaded into cells they should or that don't exist and crash
        observeItems()
    }

    // This *should* call the appropriate load based on if the user wants to see All Day or not
    // Maybe some other time when we let the user default to an all day view? ... Probably should just use a dedicated view in that case
//    func loadItems() {
//        if linesBarButtonSelected {
//            loadAllItems()
//        } else {
//            loadItemsForSegment(segment: segment ?? 0)
//        }
//    }

    var notificationToken: NotificationToken?

    // This only needs to be called once when the view is first loaded
    func observeItems() {
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
                                         with: .automatic)
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
        optionsToken?.invalidate()
    }

    // var options: Options = Options()
    // var debugOptionsToken: NotificationToken?
    var optionsToken: NotificationToken?

    func observeOptions() {
        let realm = try! Realm()
        let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
        optionsToken = options?.observe { changes in
            switch changes {
            case let .change(propertyChanged):
                propertyChanged.forEach { change in
                    if change.name == "darkMode" {
                        if change.oldValue as? Bool != change.newValue as? Bool {
                            DispatchQueue.main.async {
                                TaskTableViewController.setAppearance(forSegment: Options.getSelectedIndex())
                            }
                        }
                    }
                }
                AppDelegate.setAutomaticDarkModeTimer()
            case let .error(error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            case .deleted:
                break
            }
        }
    }

    // MARK: - Themeing

    static func setAppearance(forSegment segment: Int, function: String = #function) {
        debugPrint("Setting theme for segment: \(segment)")
        debugPrint("Called from: \(function)")
        if Options.getDarkModeStatus() {
            switch segment {
            case 1:
                Themes.switchTo(theme: .afternoonDark)
            case 2:
                Themes.switchTo(theme: .eveningDark)
            case 3:
                Themes.switchTo(theme: .nightDark)
            default:
                Themes.switchTo(theme: .morningDark)
            }
        } else {
            switch segment {
            case 1:
                Themes.switchTo(theme: .afternoonLight)
            case 2:
                Themes.switchTo(theme: .eveningLight)
            case 3:
                Themes.switchTo(theme: .nightLight)
            default:
                Themes.switchTo(theme: .morningLight)
            }
        }
    }

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

    func showStandardAlert(title: String, body: String, action: UIAlertAction?) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        if let action = action {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
