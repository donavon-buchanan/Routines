//
//  TableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import IceCream
import RealmSwift
import RxRealm
import RxSwift
import SwiftMessages
import UIKit
import UserNotifications
import ViewAnimator

class TableViewController: UITableViewController, UINavigationControllerDelegate, UITabBarControllerDelegate {
    @IBAction func unwindToTableViewController(segue _: UIStoryboardSegue) {}
    @IBOutlet var settingsBarButtonItem: UIBarButtonItem!
    @IBOutlet var addbarButtonItem: UIBarButtonItem!
    @IBOutlet var linesBarButtonItem: UIBarButtonItem!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!

    let timeLabel = UILabel()

    @IBAction func editButtonPressed(_: UIBarButtonItem) {
        setEditing()
    }

    var linesBarButtonSelected = false

    @IBAction func linesBarButtonPressed(_: UIBarButtonItem) {
        if linesBarButtonSelected {
            let cellCount = tableView.visibleCells.count
            // animateTitleChange(title: nil)
            title = setNavTitle()
            linesBarButtonSelected = false
            linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button")
            loadItems(segment: segment)
            tableView.reloadData()
            animateCells(fromCount: cellCount)
            changeTabBar(hidden: false, animated: true)
        } else {
            let cellCount = tableView.visibleCells.count
            // animateTitleChange(title: "All Tasks")
            title = "All Tasks"
            linesBarButtonSelected = true
            linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button-filled")
            loadAllItems()
            changeTabBar(hidden: true, animated: true)
            tableView.reloadData()
            animateCells(fromCount: cellCount)
        }
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
    var passedSegment: Int?
    func changeSegment(segment: Int?) {
        if let newSegment = segment {
            passedSegment = nil
            tabBarController?.selectedIndex = newSegment
            UIView.transition(with: tabBarController!.view, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            saveSelectedTab(index: newSegment)
        }
    }

    // Footer view
    let footerView = UIView()
    // var selectedTab = 0

    fileprivate func animateCells(fromCount: Int) {
//        self.view.setNeedsLayout()
//        self.view.layoutIfNeeded()
        let fromAnimation = AnimationType.from(direction: .top, offset: 64)
        let zoomAnimation = AnimationType.zoom(scale: 0.85)
        // let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)

        // Drop the cells that are already visible. Reloading them looks bad
        let cells = tableView.visibleCells.dropFirst(fromCount)
        // let nav = self.navigationController?.view
        UIView.animate(views: Array(cells), animations: [fromAnimation, zoomAnimation])
    }

    fileprivate func transitionCells(fromSegment: Int, toSegment: Int) {
        var fromAnimation: Animation {
            if fromSegment < toSegment {
                print("Animating from left")
                return AnimationType.from(direction: .left, offset: 40)
            } else {
                print("Animating from right")
                return AnimationType.from(direction: .right, offset: 40)
            }
        }
        let views = tableView.visibleCells
        UIView.animate(views: views, animations: [fromAnimation])
    }

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

        tableView.estimatedRowHeight = 64
        //tableView.rowHeight = UITableView.automaticDimension

        // Double check to save selected tab and avoid infrequent bug
        saveSelectedTab(index: tabBarController!.selectedIndex)
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
        updateBadge()
        removeDeliveredNotifications()
        title = setNavTitle()
        reloadTableView()
        setAppearance(segment: segment)
        // changeSegment(segment: passedSegment)
        setTimeInTitle(timeString: getSegmentTimeString(segment: segment))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear \n")
        changeSegment(segment: passedSegment)
        // animateCells()
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

        return DateFormatter.localizedString(from: timeOption.date!, dateStyle: .none, timeStyle: .short)
    }

    func setNavTitle() -> String {
        print("Setting table title")
        switch self.segment {
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
        if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
            index = options.selectedIndex
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

        var indicatorImage: UIImageView {
            let imageView = UIImageView()
            if (self.items?[indexPath.row].repeats)! {
                imageView.image = UIImage(imageLiteralResourceName: "repeat")
                return imageView
            } else if (self.items?[indexPath.row].disableAutoSnooze)! {
                imageView.image = UIImage(imageLiteralResourceName: "snooze-strike")
                return imageView
            } else {
                return UIImageView()
            }
        }

        // cell.delegate = self

        cell.cellTitleLabel?.text = cellTitle
        cell.cellSubtitleLabel?.text = cellSubtitle
        cell.cellIndicatorImage.image? = indicatorImage.image?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        cell.cellIndicatorImage.theme_tintColor = GlobalPicker.cellIndicatorTint

        cell.cellTitleLabel?.theme_textColor = GlobalPicker.cellTextColors
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
                return 64
            }
        } else {
            return 64
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
        items?.forEach({ item in
            do {
                try! realm.write {
                    item.isDeleted = true
                    // realm.delete(item)
                }
//                if let indexPath = self.tableView.indexPathForRow(at: CGPoint(x: 0, y: 0)) {
//                    // self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
//                }
            }
        })
        endEdit()
        OptionsTableViewController().refreshNotifications()
        updateBadge()
    }

    @objc func deleteSelectedRows() {
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            var itemArray: [Items] = []
            indexPaths.forEach({ indexPath in
                // The index paths are static during enumeration, but the item indexes are not
                // Add them to an array first, delete only what's in the array, and then update the table UI
                if let itemAtIndex = self.items?[indexPath.row] {
                    itemArray.append(itemAtIndex)
                }
            })
            itemArray.forEach { item in
                self.deleteItem(item: item)
            }
            tableView.deleteRows(at: indexPaths, with: .left)
        }
        OptionsTableViewController().refreshNotifications()
        updateBadge()
    }

//    //Delay func
//    func delay(_ delay:Double, closure:@escaping ()->()) {
//        DispatchQueue.main.asyncAfter(
//            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
//    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
        // super.updateModel(at: indexPath)
        print("Removing item with indexPath: \(indexPath)")
        do {
            try! realm.write {
                if let item = self.items?[indexPath.row] {
                    self.removeNotification(uuidString: ["\(item.uuidString)0", "\(item.uuidString)1", "\(item.uuidString)2", "\(item.uuidString)3", item.uuidString])
                    print("removing item with key: \(item.uuidString)")
                    item.isDeleted = true
                    // realm.delete(item)
                }
            }
        }
        // Index path still needs to be updated to prevent trying to delete out of bounds
        //tableView.deleteRows(at: [indexPath], with: .left)
        OptionsTableViewController().refreshNotifications()
        updateBadge()
    }

    func snoozeItem(indexPath: IndexPath) {
        do {
            try! realm.write {
                if let item = self.items?[indexPath.row] {
                    switch item.segment {
                    case 0:
                        item.segment = 1

                        showBanner(title: "Task Snoozed to Afternoon")
                    case 1:
                        item.segment = 2

                        showBanner(title: "Task Snoozed to Evening")
                    case 2:
                        item.segment = 3

                        showBanner(title: "Task Snoozed to Night")
                    default:
                        item.segment = 0

                        showBanner(title: "Task Snoozed to Morning")
                    }
                }
            }
        }
        // Don't remove the row if viewing all items because it still exists
        if !linesBarButtonSelected {
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        tableView.reloadData()
        OptionsTableViewController().refreshNotifications()
        updateBadge()
    }

    func setItemToIgnore(indexPath: IndexPath, ignore: Bool) {
        do {
            try! realm.write {
                if let item = self.items?[indexPath.row] {
                    item.disableAutoSnooze = ignore
                }
            }
        }
        OptionsTableViewController().refreshNotifications()
    }

    // TODO: Animated reload would be nice
    func reloadTableView() {
        tableView.reloadData()
    }

    // Set background graphic
    func setViewBackgroundGraphic(enabled: Bool) {
        if enabled {
            let backgroundImageView = UIImageView()
            let backgroundImage = UIImage(imageLiteralResourceName: "inlay")

            backgroundImageView.image = backgroundImage
            backgroundImageView.contentMode = .scaleAspectFit

            tableView.backgroundView = backgroundImageView
            view.setNeedsDisplay()
            view.layoutIfNeeded()
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

    // Get the default Realm
    lazy var realm = try! Realm()
    let bag = DisposeBag()

    let optionsKey = "optionsKey"

    // Each view (tab) loads its own set of items.
    // Load from viewDidLoad. Reload table from viewWillAppear

    /* TODO: Change this back to a list of realm objects and create a new array var for the rest of below to work with.
     The table should load and count from the realm list, not the array.
     Make sure to re-enable reloads and counts.
     */
    // var items: [Items]?
    var items: Results<Items>? {
        willSet {}

        didSet {
            tableView.reloadData()
        }
    }
    public var segment = Int()

    func loadItems(segment: Int) {
        items = realm.objects(Items.self).filter("segment = \(segment) AND isDeleted = \(false)").sorted(byKeyPath: "dateModified", ascending: true)
        //        Made this more Swift-y by using willSet and didSet above
//        Observable.array(from: items).subscribe(onNext: { items in
//            /// When data changes in Realm, the following code will be executed
//            // self.items = items.filter("segment = \(segment) AND isDeleted = \(false)").sorted(byKeyPath: "dateModified", ascending: true)
//            self.items = items.filter({ !$0.isDeleted || $0.segment == self.segment })
//            self.tableView.reloadData()
//        }).disposed(by: bag)
    }
    func loadAllItems() {
        // Sort by segment to put in order of the day
        items = realm.objects(Items.self).filter("isDeleted = \(false)").sorted(byKeyPath: "segment", ascending: true)
    }

    private func deleteItem(item: Items) {
        do {
            try realm.write {
                item.isDeleted = true
                // realm.delete(item)
            }
        } catch {
            print("failed to delete item")
        }
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
        if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
            darkMode = options.darkMode
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
        let items = realm.objects(Items.self).filter("segment = \(fromSegment) AND isDeleted = \(false) AND disableAutoSnooze = %@", false)
        items.forEach({ item in
            if let itemDate = item.dateModified {
                if itemDate < Date() {
                    do {
                        try realm.write {
                            item.segment = toSegment
                        }
                    } catch {
                        print("failed to autoSnooze items")
                    }
                }
            }
        })
    }

    func getAutoSnoozeStatus() -> Bool {
        var snooze = false
        if let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
            snooze = options.smartSnooze
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
        return hour
    }

    func getOptionMinute(segment: Int) -> Int {
        var minute = Int()
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
