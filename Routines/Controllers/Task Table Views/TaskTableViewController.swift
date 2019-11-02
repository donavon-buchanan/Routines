//
//  TaskTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import UIKit
import UserNotifications

class TaskTableViewController: UITableViewController, UINavigationControllerDelegate, UITabBarControllerDelegate {
    
    @IBAction func unwindToTableViewController(segue _: UIStoryboardSegue) {}
    @IBOutlet var settingsBarButtonItem: UIBarButtonItem!
    @IBOutlet var addbarButtonItem: UIBarButtonItem!
    @IBOutlet var linesBarButtonItem: UIBarButtonItem!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!

    override var keyCommands: [UIKeyCommand]? {
        var commandArray: [UIKeyCommand]
        commandArray = [
            UIKeyCommand(title: "Add New Task", action: #selector(addNewTask), input: "n", modifierFlags: .command),
            UIKeyCommand(title: "Open Settings", action: #selector(openSettings), input: "o", modifierFlags: .alternate),
            UIKeyCommand(title: "Edit List", action: #selector(editKeyCommand), input: "e", modifierFlags: .init(arrayLiteral: .shift, .command)),
            UIKeyCommand(title: "Show Entire Day", action: #selector(showAllKeyCommand), input: "a", modifierFlags: .init(arrayLiteral: .shift, .command)),
        ]
        if !linesBarButtonSelected {
            commandArray.append(contentsOf: [
                UIKeyCommand(title: "Select Morning", action: #selector(setSegmentZero), input: "1", modifierFlags: .command),
                UIKeyCommand(title: "Select Afternoon", action: #selector(setSegmentOne), input: "2", modifierFlags: .command),
                UIKeyCommand(title: "Select Evening", action: #selector(setSegmentTwo), input: "3", modifierFlags: .command),
                UIKeyCommand(title: "Select Night", action: #selector(setSegmentThree), input: "4", modifierFlags: .command),
            ])
        }
        return commandArray
    }

    @objc func setSegmentZero() {
        guard let tabBarController = tabBarController else { return }
        tabBarController.selectedIndex = 0
//        TaskTableViewController.setAppearance(forSegment: 0)
    }

    @objc func setSegmentOne() {
        guard let tabBarController = tabBarController else { return }
        tabBarController.selectedIndex = 1
//        TaskTableViewController.setAppearance(forSegment: 1)
    }

    @objc func setSegmentTwo() {
        guard let tabBarController = tabBarController else { return }
        tabBarController.selectedIndex = 2
//        TaskTableViewController.setAppearance(forSegment: 2)
    }

    @objc func setSegmentThree() {
        guard let tabBarController = tabBarController else { return }
        tabBarController.selectedIndex = 3
//        TaskTableViewController.setAppearance(forSegment: 3)
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
            loadAllTasks()
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
        let clearButton = UIBarButtonItem(title: "Complete", style: .plain, target: self, action: #selector(showClearAlert))
        navigationItem.leftBarButtonItems = [clearButton]
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedAlert))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEdit))
        navigationItem.rightBarButtonItems = [doneButton, trashButton]
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
        debugPrint(#function + " start")

        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.willEnterForegroundNotification, object: nil)

        tableView.allowsMultipleSelectionDuringEditing = true

        tabBarController?.delegate = self
        navigationController?.delegate = self

        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        tableView.estimatedRowHeight = 115
        tableView.rowHeight = UITableView.automaticDimension
        
        super.viewDidLoad()

        debugPrint(#function + " end")
    }
    
    override func applicationFinishedRestoringState() {
        super.applicationFinishedRestoringState()
    }

    @objc func appBecameActive() {
        debugPrint(#function + " start")
        observeTasks()
        debugPrint(#function + " end")
    }
    
    func returnSegment() -> Int {
        return 0
    }


    override func viewWillAppear(_ animated: Bool) {
        debugPrint(#function + " start")
        
        loadTasksForSegment(segment: returnSegment())
        
        title = returnTitle(forSegment: returnSegment() )
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(segment: returnSegment())]
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(segment: returnSegment())]
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(segment: returnSegment())]
        navigationController?.navigationBar.tintColor = UIColor(segment: returnSegment())
        navigationBarAppearance.buttonAppearance = buttonAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        tabBarController?.tabBar.tintColor = UIColor(segment: returnSegment())
        
        super.viewWillAppear(animated)
        
        debugPrint(#function + " end")
    }

    func returnTitle(forSegment segment: Int) -> String {
        debugPrint(#function + " segment: \(segment)")
        switch segment {
        case 0:
            return AppStrings.TimePeriod.morning.rawValue.localizedCapitalized
        case 1:
            return AppStrings.TimePeriod.afternoon.rawValue.localizedCapitalized
        case 2:
            return AppStrings.TimePeriod.evening.rawValue.localizedCapitalized
        default:
            return AppStrings.TimePeriod.night.rawValue.localizedCapitalized
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect _: UIViewController) {
        Options.setSelectedIndex(index: tabBarController.selectedIndex)
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        debugPrint("Items count for number of rows is " + String(describing: tasks?.count))
        return tasks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }

        // Realm occasionally throws an error here. Use guard to return early if the task no-longer exist.
        guard let task = tasks?[indexPath.row] else {
            debugPrint("Failed to fetch task from index path. Returning empty cell")
            return cell
        }

        let segment = task.segment
        let cellTitle: String = task.title!
        var cellSubtitle: String? {
            if let subtitle = task.notes {
                if !subtitle.isEmpty {
                    return subtitle
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        var repeatLabel: String {
            if task.completeUntil < Date().endOfDay {
                if task.repeats {
                    return "Repeats Daily"
                } else {
                    return ""
                }
            } else {
                if task.repeats {
                    return "Tomorrow - Repeats Daily"
                } else {
                    return "Tomorrow"
                }
            }
        }

        if linesBarButtonSelected {
            cell.configColorBar(segment: segment)
        } else {
            cell.configColorBar(segment: nil)
        }

        cell.repeatLabel?.text = repeatLabel
        cell.repeatLabel?.textColor = UIColor(segment: segment)

        cell.cellTitleLabel?.text = cellTitle
        cell.cellSubtitleLabel?.text = cellSubtitle

        if task.completeUntil > Date().endOfDay {
            cell.cellTitleLabel.textColor = .lightGray
            cell.cellSubtitleLabel.textColor = .lightGray
            cell.repeatLabel.textColor = .lightGray
        }

        return cell
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        true
    }

    var shouldAllowRearranging: Bool = true

    // Override to support conditional rearranging of the table view.
    override func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        // Return false if you do not want the task to be re-orderable.
        shouldAllowRearranging
    }

    // Override to support rearranging the table view.
    override func tableView(_: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if let realm = try? Realm() {
            realm.beginWrite()
            tasks?.move(from: fromIndexPath.row, to: to.row)
            if let notificationToken = notificationToken {
                do {
                    try realm.commitWrite(withoutNotifying: [notificationToken])
                } catch {
                    realm.cancelWrite()
                }
            } else {
                do {
                    try realm.commitWrite()
                } catch {
                    realm.cancelWrite()
                }
            }
        }
    }

    override func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let task = tasks?[indexPath.row] else { return nil }
        let taskSegment = task.segment
        var nextColor: UIColor {
            switch taskSegment {
            case 1:
                return UIColor(displayP3Red: 0.38, green: 0.64, blue: 0.53, alpha: 1.0)
            case 2:
                return UIColor(displayP3Red: 0.39, green: 0.36, blue: 0.91, alpha: 1.0)
            case 3:
                return UIColor(displayP3Red: 0.96, green: 0.46, blue: 0.27, alpha: 1.0)
            default:
                return UIColor(displayP3Red: 0.15, green: 0.73, blue: 0.93, alpha: 1.0)
            }
        }

        let completeAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.completeTaskAtIndex(at: indexPath)
            completion(true)
        }
        let snoozeAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.snoozeTask(indexPath: indexPath)
            if !self.linesBarButtonSelected {
                completion(true)
            } else {
                completion(false)
            }
        }
        let nextSectionAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            debugPrint("\(#function) - indexPath: \(String(describing: indexPath))")
            self.moveTaskToNext(indexPath: indexPath)
            if !self.linesBarButtonSelected {
                completion(true)
            } else {
                completion(false)
            }
        }

        completeAction.image = UIImage(imageLiteralResourceName: "checkmark").withTintColor(.white, renderingMode: .alwaysTemplate)
        completeAction.backgroundColor = ColorPicker.mainColor
        snoozeAction.backgroundColor = ColorPicker.snoozeColor
        snoozeAction.image = UIImage(systemName: "bell.slash.fill")
        nextSectionAction.backgroundColor = nextColor
        nextSectionAction.image = UIImage(systemName: "arrowshape.turn.up.right.fill")

        var arrayOfActions: [UIContextualAction] = []
        if task.completeUntil < Date().endOfDay {
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
        deleteAction.image = UIImage(systemName: "trash")
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
//        showAlert(title: "Are you sure?", body: "This will mark all the tasks shown as completed. Repeating tasks will still appear again tomorrow.")
        let action = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            if let selectedCount = self.tableView.indexPathsForSelectedRows?.count {
                switch selectedCount {
                case 0:
                    self.clearAll()
                default:
                    self.completeSelectedRows()
                }
            } else {
                self.clearAll()
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        var body: String {
            if let selectedCount = self.tableView.indexPathsForSelectedRows?.count {
                switch selectedCount {
                case 0:
                    return "Are you sure you want to clear all tasks shown?"
                case 1:
                    return "Are you sure you want to clear the selected task?"
                default:
                    return "Are you sure you want to clear \(selectedCount) selected tasks?"
                }
            } else {
                return "Are you sure you want to clear all tasks shown?"
            }
        }
        let alertController = UIAlertController(title: "Complete Tasks", message: body, preferredStyle: .alert)
        alertController.addAction(cancel)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func clearAll() {
        debugPrint(#function)
        var taskAray: [Task] = []

        if let tasks = tasks {
            taskAray.append(contentsOf: tasks)
        }

        Task.batchComplete(taskArray: taskAray)

        endEdit()
        // resetTableView()
        // changeTabBar(hidden: false, animated: true)
    }

    func completeSelectedRows() {
        debugPrint(#function)

        var tasksToComplete: [Task] = []

        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            indexPaths.forEach { indexPath in
                // The index paths are static during enumeration, but the task indexes are not
                // Add them to an array first, delete only what's in the array, and then update the table UI
                if let taskAtIndex = tasks?[indexPath.row] {
                    debugPrint("Appending task titled \(taskAtIndex.title!) ")
                    tasksToComplete.append(taskAtIndex)
                }
            }
            Task.batchComplete(taskArray: tasksToComplete)
        }
    }

    @objc func deleteSelectedRows() {
        var taskCount: Int {
            if let tasks = tasks {
                return tasks.count
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

        var tasksToDelete: [Task] = []

        if selectedCount != 0 {
            if let indexPaths = self.tableView.indexPathsForSelectedRows {
                var taskArray: [Task] = []
                indexPaths.forEach { indexPath in
                    // The index paths are static during enumeration, but the task indexes are not
                    // Add them to an array first, delete only what's in the array, and then update the table UI
                    if let taskAtIndex = tasks?[indexPath.row] {
                        taskArray.append(taskAtIndex)
                    }
                }

                taskArray.forEach { task in
                    tasksToDelete.append(task)
                }
                Task.batchDelete(taskArray: tasksToDelete)
            }
        } else if selectedCount == 0, taskCount != 0 {
            tasks?.forEach { task in
                tasksToDelete.append(task)
            }
            Task.batchDelete(taskArray: tasksToDelete)
            endEdit()
            resetTableView()
            changeTabBar(hidden: false, animated: true)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func resetTableView() {
        // Reset the view just before segue
        if linesBarButtonSelected {
            title = returnTitle(forSegment: returnSegment())
            DispatchQueue.main.async {
                autoreleasepool {
                    self.linesBarButtonSelected = false
                    self.linesBarButtonItem.image = UIImage(imageLiteralResourceName: "lines-button")
                    self.loadTasksForSegment(segment: self.returnSegment())
                    self.changeTabBar(hidden: false, animated: true)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "addSegue" {
            let navVC = segue.destination as? UINavigationController
            let destination = navVC?.topViewController as? AddTableViewController
            // set segment based on current tab
            let selectedTab = returnSegment()
            destination?.editingSegment = selectedTab
            destination?.selectedIndex = selectedTab
            resetTableView()
        }

        if segue.identifier == "editSegue" {
            let navVC = segue.destination as? UINavigationController
            let destination = navVC?.topViewController as? AddTableViewController

            // pass in current task
            if let indexPath = tableView.indexPathForSelectedRow {
                destination?.task = tasks?[indexPath.row]
            }
        }

        if segue.identifier == "optionsSegue" {
            let navVC = segue.destination as? UINavigationController
            let destination = navVC?.topViewController as? OptionsTableViewController
            destination?.selectedIndex = returnSegment()
        }

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    // MARK: - Model Manipulation Methods

    // Override empty delete func from super
    func softDeleteAtIndex(at indexPath: IndexPath) {
        if let task = tasks?[indexPath.row] {
            task.deleteTask()
            //            updateBadge()
        }
    }

    func completeTaskAtIndex(at indexPath: IndexPath) {
        if let task = tasks?[indexPath.row] {
            task.completeTask()
        }
    }

    func snoozeTask(indexPath: IndexPath) {
        guard let task = tasks?[indexPath.row] else { return }
        task.snooze()
    }

    func moveTaskToNext(indexPath: IndexPath) {
        guard let task = tasks?[indexPath.row] else { return }
        task.moveToNextSegment()
    }

    // MARK: - Manage Notifications

    // MARK: - Realm

    var tasks: List<Task>?

    func loadTasksForSegment(segment: Int) {
        debugPrint("loading tasks for segment \(segment)")
        shouldAllowRearranging = true
        let taskCategory = TaskCategory.returnTaskCategory(segment)
        if RoutinesPlus.getShowUpcomingTasks() {
            tasks = taskCategory.taskList // .filter("segment = \(segment) AND isDeleted = \(false)").sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "completeUntil", ascending: true)
        } else {
            tasks = taskCategory.taskList // .filter("segment = \(segment) AND isDeleted = \(false) AND completeUntil < %@", Date().endOfDay).sorted(byKeyPath: "dateModified", ascending: true).sorted(byKeyPath: "priority", ascending: false)
        }
        observeTasks()
    }

    func loadAllTasks() {
        debugPrint("loading all tasks")
        shouldAllowRearranging = false
        // Sort by segment to put in order of the day
        if let realm = try? Realm() {
            let taskList = TaskCategory.returnTaskCategory(CategorySelections.allDay.rawValue).taskList
            let mlist = TaskCategory.returnTaskCategory(CategorySelections.morning.rawValue).taskList
            let alist = TaskCategory.returnTaskCategory(CategorySelections.afternoon.rawValue).taskList
            let elist = TaskCategory.returnTaskCategory(CategorySelections.evening.rawValue).taskList
            let nlist = TaskCategory.returnTaskCategory(CategorySelections.night.rawValue).taskList
            do {
                // Prevents notification chaos by using beginWrite
                realm.beginWrite()
                let tasks = taskList.sorted(byKeyPath: "segment", ascending: false)
                debugPrint("tasks: " + String(describing: tasks.count))
                taskList.removeAll()
                taskList.append(objectsIn: mlist)
                taskList.append(objectsIn: alist)
                taskList.append(objectsIn: elist)
                taskList.append(objectsIn: nlist)
                debugPrint("tasksList: " + String(describing: taskList.count))

                try realm.commitWrite()
            } catch {
                realm.cancelWrite()
            }
            tasks = TaskCategory.returnTaskCategory(CategorySelections.allDay.rawValue).taskList

            observeTasks()
        }
    }

    var notificationToken: NotificationToken?

    // This only needs to be called once when the view is first loaded
    func observeTasks() {
        // Observe Results Notifications
        notificationToken = tasks?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                debugPrint("Initial load")
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case let .update(_, deletions, insertions, modifications):
                debugPrint("update detected")
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
                debugPrint("Error in \(#function) - \(error)")
            }
        }
    }

    deinit {
        debugPrint("\(#function) called. Tokens invalidated")
        notificationToken?.invalidate()
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
        var taskCount: Int {
            if let tasks = self.tasks {
                return tasks.count
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
        } else if selectedCount == 0, taskCount != 0 {
            if taskCount == 1 {
                alertController.message = "This will permanently delete the task shown."
            } else {
                alertController.message = "This will permanently delete all \(taskCount) tasks shown."
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

    func showStandardAlert(title: String, body: String, action: UIAlertAction?) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        if let action = action {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
