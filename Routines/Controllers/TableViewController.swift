//
//  TableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

// import IceCream
import RealmSwift
// import RxRealm
// import RxSwift
import SwiftMessages
import UIKit
import UserNotifications
// import ViewAnimator

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
            UIKeyCommand(input: "a", modifierFlags: .init(arrayLiteral: .shift, .command), action: #selector(showAllKeyCommand), discoverabilityTitle: "Reveal All Tasks"),
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
            // let cellCount = tableView.visibleCells.count
            // animateTitleChange(title: nil)
            title = setNavTitle()
            linesBarButtonSelected = false
            linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button")
            loadItems(segment: segment)
            tableView.reloadData()

            // animation broken by realmSync
            // animateCells(fromCount: cellCount)
            changeTabBar(hidden: false, animated: true)
        } else {
            // let cellCount = tableView.visibleCells.count
            // animateTitleChange(title: "All Tasks")
            title = "All Tasks"
            linesBarButtonSelected = true
            linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button-filled")
            loadAllItems()
            changeTabBar(hidden: true, animated: true)
            tableView.reloadData()
            // animateCells(fromCount: cellCount)
        }
    }

    @IBAction func linesBarButtonPressed(_: UIBarButtonItem) {
        revealAllTasks()
    }

//    func animateTitleChange(title: String?) {
//        UIView.transition(with: (self.navigationController?.navigationBar)!, duration: 0.3, options: .transitionCrossDissolve, animations: {
//            if let newTitle = title {
//                self.title = newTitle
//            } else {
//                self.title = self.setNavTitle()
//            }
//        }, completion: nil)
//    }

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
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedRows))
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

    // Set segment after adding an item
//    var passedSegment: Int?
//    func changeSegment(segment: Int?) {
//        if let newSegment = segment {
//            passedSegment = nil
//            tabBarController?.selectedIndex = newSegment
//            UIView.transition(with: tabBarController!.view, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
//            saveSelectedTab(index: newSegment)
//        }
//    }

    // Footer view
    let footerView = UIView()
    // var selectedTab = 0

//    fileprivate func animateCells(fromCount: Int) {
    ////        self.view.setNeedsLayout()
    ////        self.view.layoutIfNeeded()
//        let fromAnimation = AnimationType.from(direction: .top, offset: 64)
//        let zoomAnimation = AnimationType.zoom(scale: 0.85)
//        // let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
//
//        // Drop the cells that are already visible. Reloading them looks bad
//        let cells = tableView.visibleCells.dropFirst(fromCount)
//        // let nav = self.navigationController?.view
//        UIView.animate(views: Array(cells), animations: [fromAnimation, zoomAnimation])
//    }

//    fileprivate func transitionCells(fromSegment: Int, toSegment: Int) {
//        var fromAnimation: Animation {
//            if fromSegment < toSegment {
//                print("Animating from left")
//                return AnimationType.from(direction: .left, offset: 40)
//            } else {
//                print("Animating from right")
//                return AnimationType.from(direction: .right, offset: 40)
//            }
//        }
//        let views = tableView.visibleCells
//        UIView.animate(views: views, animations: [fromAnimation])
//    }

    override func viewDidLoad() {
        print("Running viewDidLoad")
        super.viewDidLoad()

        tableView.allowsMultipleSelectionDuringEditing = true

        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil)

        // center.delegate = self

        tabBarController?.delegate = self
        navigationController?.delegate = self
        segment = tabBarController?.selectedIndex ?? 0

        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        setViewBackgroundGraphic(enabled: true)

        loadItems(segment: segment)

        //tableView.estimatedRowHeight = 120
        //tableView.rowHeight = UITableView.automaticDimension

        // Double check to save selected tab and avoid infrequent bug
        saveSelectedTab(index: tabBarController!.selectedIndex)

        // realmSync()
    }

    @objc func appBecameActive() {
        runAutoSnooze()
        removeDeliveredNotifications()
        updateBadge()
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear")
        runAutoSnooze()
        removeDeliveredNotifications()
        title = setNavTitle()
        // reloadTableView()
        // setAppearance(segment: segment)
        // changeSegment(segment: passedSegment)
        // setTimeInTitle(timeString: getSegmentTimeString(segment: segment))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear \n")
        // changeSegment(segment: passedSegment)
        // animateCells()
        setAppearance(segment: segment)
        // changeSegment(segment: passedSegment)
    }

    func setTimeInTitle(timeString _: String) {
//        timeLabel.text = timeString
//        timeLabel.theme_textColor = GlobalPicker.barTextColor
//        navigationItem.titleView = timeLabel
//
//        // need to re-layout title since it can be changed
//        navigationItem.titleView?.setNeedsUpdateConstraints()
    }

    func getSegmentTimeString(segment: Int) -> String {
        var timeString: String = ""
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)
                var timeOption = DateComponents()
                timeOption.calendar = Calendar.autoupdatingCurrent
                timeOption.timeZone = TimeZone.autoupdatingCurrent

                switch segment {
                case 1:
                    timeOption.hour = options?.afternoonHour
                    timeOption.minute = options?.afternoonMinute
                case 2:
                    timeOption.hour = options?.eveningHour
                    timeOption.minute = options?.eveningMinute
                case 3:
                    timeOption.hour = options?.nightHour
                    timeOption.minute = options?.nightMinute
                default:
                    timeOption.hour = options?.morningHour
                    timeOption.minute = options?.morningMinute
                }

                timeString = DateFormatter.localizedString(from: timeOption.date!, dateStyle: .none, timeStyle: .short)
            }
        }
        return timeString
    }

    func setNavTitle() -> String {
        print("Setting table title")
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
        saveSelectedTab(index: tabBarController.selectedIndex)
    }

    func saveSelectedTab(index: Int) {
        print("saving tab as index: \(index)")
        // let selectedIndex = self.tabBarController?.selectedIndex
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

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskTableViewCell

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

//        var indicatorImage: UIImageView {
//            let imageView = UIImageView()
//            if (self.items?[indexPath.row].repeats)! {
//                imageView.image = UIImage(imageLiteralResourceName: "repeat")
//                return imageView
//            } else if (self.items?[indexPath.row].disableAutoSnooze)! {
//                imageView.image = UIImage(imageLiteralResourceName: "snooze-strike")
//                return imageView
//            } else {
//                return UIImageView()
//            }
//        }

        // cell.delegate = self

        cell.cellTitleLabel?.text = cellTitle
        cell.cellSubtitleLabel?.text = cellSubtitle
        // cell.cellIndicatorImage.image? = indicatorImage.image?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        // cell.cellIndicatorImage.theme_tintColor = GlobalPicker.cellIndicatorTint

        cell.cellTitleLabel?.theme_textColor = GlobalPicker.cellTextColors
        cell.repeatLabel?.theme_textColor = GlobalPicker.barTextColor
        cell.theme_backgroundColor = GlobalPicker.backgroundColor
        let cellSelectedBackgroundView = UIView()
        cellSelectedBackgroundView.theme_backgroundColor = GlobalPicker.cellBackground
        cell.selectedBackgroundView = cellSelectedBackgroundView
        cell.multipleSelectionBackgroundView = cellSelectedBackgroundView

        return cell
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let completeAction = UITableViewRowAction(style: .destructive, title: "Complete") { _, indexPath in
            self.updateModel(at: indexPath)
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
            self.updateModel(at: indexPath)
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
        // TODO: Image is not centered
        completeAction.image = UIImage(imageLiteralResourceName: "checkmark")
        completeAction.backgroundColor = UIColor(red: 0.30, green: 0.43, blue: 1.00, alpha: 1.00)
        snoozeAction.backgroundColor = .orange
        snoozeAction.image = UIImage(imageLiteralResourceName: "snooze")
        let actions = UISwipeActionsConfiguration(actions: [completeAction, snoozeAction])
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
//            updateModel(at: indexPath)
//            self.tableView.deleteRows(at: [indexPath], with: .left)
//        }
//    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let notes = items?[indexPath.row].notes {
            if notes.count > 0 {
                return UITableView.automaticDimension
            } else {
                return 80
            }
        } else {
            return 80
        }
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
        print("Selected index paths: \(String(describing: tableView.indexPathsForSelectedRows))")
    }

    @objc func showClearAlert() {
        showAlert(title: "Are you sure?", body: "This will clear all the tasks shown.")
    }

    @objc private func clearAll() {
        items?.forEach { item in
            // TODO: Might be better to just grab a whole filtered list and then delete from there
            item.softDelete() // item.deleteItem()
            updateBadge()
        }
        endEdit()
        resetTableView()
        changeTabBar(hidden: false, animated: true)
    }

    @objc func deleteSelectedRows() {
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
                item.softDelete() // item.deleteItem()
                updateBadge()
            }
            // This will be handled by the realmSync func
            //tableView.deleteRows(at: indexPaths, with: .left)
        }
//        OptionsTableViewController().refreshNotifications()
//        updateBadge()
    }

//    //Delay func
//    func delay(_ delay:Double, closure:@escaping ()->()) {
//        DispatchQueue.main.asyncAfter(
//            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
//    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    fileprivate func resetTableView() {
        // Reset the view just before segue
        if linesBarButtonSelected {
            title = setNavTitle()
            DispatchQueue.main.async {
                autoreleasepool {
                    self.linesBarButtonSelected = false
                    self.linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button")
                    self.loadItems(segment: self.segment)
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

        resetTableView()
    }

    // MARK: - Model Manipulation Methods

//    func loadData() -> Results<Items> {
//        return realm.objects(Items.self)
//    }

    // Filter items to relevant segment and return those items
//    func loadItems(segment: Int) -> Results<Items> {
//        guard let filteredItems = items?.filter("segment = \(segment)") else { fatalError() }
//        print("loadItems run")
//        //self.tableView.reloadData()
//        return filteredItems
//    }

    // Override empty delete func from super
    func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            item.softDelete() // item.deleteItem()
            updateBadge()
        }
    }

    func snoozeItem(indexPath: IndexPath) {
        guard let item = items?[indexPath.row] else { return }
        item.snooze()
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
        AppDelegate().updateAppBadgeCount()
    }

    func getCountForTab(_ tab: Int) -> Int {
        let realm = try! Realm()
        // TODO: The "isDeleted" filter is going to cause problems. Way too much code repetition. Do better.
        return realm.objects(Items.self).filter("segment = %@ AND dateModified < %@ AND isDeleted = %@", tab, Date(), false).count
    }

    // MARK: - Manage Notifications

    let center = UNUserNotificationCenter.current()

    func removeNotification(uuidString: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidString)
    }

    func removeDeliveredNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notifications in
            for notification in notifications {
                // TODO: If repeats, remove and then add again
                // Get the ID and then get the properties of the specific object
                // Need to get all the same notification functions used in other views to be able to create
                center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
            }
        }
    }

    // Notification Settings Screen
//    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
//        print("Opening settings")
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let optionsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsView") as! OptionsTableViewController
//        self.navigationController?.pushViewController(optionsViewController, animated: true)
//    }

    // MARK: - Realm

    let optionsKey = "optionsKey"

    var items: Results<Items>?

    public var segment = Int()

//    public func refreshItems() {
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool{
//                let realm = try! Realm()
//                self.items = realm.objects(Items.self).filter("isDeleted = \(false)")
//            }
//        }
//    }

    func loadItems(segment: Int) {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                self.items = realm.objects(Items.self).filter("segment = \(segment) AND isDeleted = \(false)").sorted(byKeyPath: "dateModified", ascending: true)
            }
        }
        realmSync(itemsToObserve: items!)
    }

    func loadAllItems() {
        // Sort by segment to put in order of the day
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                self.items = realm.objects(Items.self).filter("isDeleted = \(false)").sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "segment", ascending: true)
            }
        }
        realmSync(itemsToObserve: items!)
    }

//    private func deleteItem(item: Items) {
//        item.softDelete() // item.deleteItem()
//        updateBadge()
//    }
//
    var notificationToken: NotificationToken?

    func realmSync(itemsToObserve _: Results<Items>) {
        // TODO: https://realm.io/docs/swift/latest/#interface-driven-writes
        // Observe Results Notifications
        notificationToken = items?.observe { [self] (changes: RealmCollectionChange) in
            guard let tableView = self.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                self.updateBadge()
            case let .update(_, deletions, insertions, modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.performBatchUpdates({
                    tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                         with: .automatic)
                    tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
                                         with: .automatic)
                }, completion: nil)
                self.updateBadge()
            case let .error(error):
                // An error occurred while opening the Realm file on the background worker thread
                print("\(error)")
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }

    // MARK: - Themeing

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

    public func getDarkModeStatus() -> Bool {
        var darkMode = false
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                do {
                    let realm = try! Realm()
                    if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                        darkMode = options.darkMode
                    }
                }
            }
        }
        return darkMode
    }

    // MARK: - Smart Snooze

    // Run this first
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
                segmentsToSnooze = [0, 1]
            case 3:
                segmentsToSnooze = [0, 1, 2]
            default:
                segmentsToSnooze = [1, 2, 3]
            }

            segmentsToSnooze.forEach { segment in
                autoSnoozeMove(fromSegment: segment, toSegment: currentSegment)
            }
        }
    }

    // This does the work
    func autoSnoozeMove(fromSegment: Int, toSegment: Int) {
        print("running autoSnoozeMove from segment \(fromSegment) to \(toSegment)")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let items = realm.objects(Items.self).filter("segment = \(fromSegment) AND isDeleted = \(false) AND disableAutoSnooze = %@", false)
                items.forEach { item in
                    if item.dateModified < Date() {
                        item.snooze()
                    }
                }
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
                let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)
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

    // MARK: - Banners

    func showBanner(title: String?) {
        SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: .statusBar)
        SwiftMessages.pauseBetweenMessages = 0
        SwiftMessages.hideAll()
        SwiftMessages.show { () -> UIView in
            let banner = MessageView.viewFromNib(layout: .statusLine)
            banner.configureTheme(.success)
            banner.configureContent(title: "", body: title ?? "Task Snoozed")
            return banner
        }
    }

    func showAlert(title: String, body: String) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .center
        config.duration = .forever

        let alert = MessageView.viewFromNib(layout: .cardView)
        let icon = "💥"
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

        if getDarkModeStatus() {
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.dimModeAccessibilityLabel = "Dismiss Warning"
        } else {
            config.dimMode = .blur(style: .regular, alpha: 1, interactive: true)
            config.dimModeAccessibilityLabel = "Dismiss Warning"
        }

        SwiftMessages.show(config: config, view: alert)
    }
}
