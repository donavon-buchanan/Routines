//
//  OptionsTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import UIKit
import UserNotifications

// enum RegisteredPurchase: String {
//    case lifetime = "lifetime1"
//    case yearly = "routines_plus_yearly"
//    case monthly = "routines_plus_monthly"
// }

class OptionsTableViewController: UITableViewController {
    let notificationHandler = NotificationHandler()

    var selectedIndex: Int?

    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var switches: [UISwitch]!

    @IBOutlet var morningSwitch: UISwitch!
    @IBOutlet var afternoonSwitch: UISwitch!
    @IBOutlet var eveningSwitch: UISwitch!
    @IBOutlet var nightSwitch: UISwitch!

    @IBOutlet var morningSubLabel: UILabel!
    @IBOutlet var afternoonSubLabel: UILabel!
    @IBOutlet var eveningSubLabel: UILabel!
    @IBOutlet var nightSubLabel: UILabel!

    // MARK: - Advanced

//    @IBOutlet var cloudSyncLabel: UILabel!
//    @IBOutlet var cloudSyncSwitch: UISwitch!
//    @IBAction func cloudSyncSwitchToggled(_ sender: UISwitch) {
//        let realm = try! Realm()
//        let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())
//        routinesPlus?.setCloudSync(toggle: cloudSyncSwitch.isOn)
//        debugPrint("Cloud sync switch: \(sender.isOn)")
//    }
//
//    @IBOutlet var upcomingTasksCellLabel: UILabel!
    ////    @IBOutlet var upcomingTasksCellStatusLabel: UILabel!
//    @IBOutlet var upcomingTasksSwitch: UISwitch!
//    @IBAction func upcomingTasksSwitchToggled(_ sender: UISwitch) {
//        RoutinesPlus.setUpcomingTasks(sender.isOn)
//        debugPrint("Upcoming tasks switch: \(sender.isOn)")
//    }

    // MARK: Automatic Dark Mode

//    @IBOutlet var automaticDarkModeLabel: UILabel!
//    @IBOutlet var automaticDarkModeStatusLabel: UILabel!

    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(title: "Exit", action: #selector(dismissView), input: "w", modifierFlags: .init(arrayLiteral: .command)),
        ]
    }

    @IBAction func notificationSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            notificationHandler.checkNotificationPermission()
        }
        switch sender.tag {
        case 1:
            Options.setSegmentNotification(segment: 1, bool: sender.isOn)
            let tasks = TaskCategory.returnTaskCategory(sender.tag).taskList
            notificationHandler.batchModifyNotifications(tasks: Array(tasks))
        // print("Afternoon Switch Toggled \(sender.isOn)")
        case 2:
            Options.setSegmentNotification(segment: 2, bool: sender.isOn)
            let tasks = TaskCategory.returnTaskCategory(sender.tag).taskList
            notificationHandler.batchModifyNotifications(tasks: Array(tasks))
        // print("Evening Switch Toggled \(sender.isOn)")
        case 3:
            Options.setSegmentNotification(segment: 3, bool: sender.isOn)
            let tasks = TaskCategory.returnTaskCategory(sender.tag).taskList
            notificationHandler.batchModifyNotifications(tasks: Array(tasks))
        // print("Night Switch Toggled \(sender.isOn)")
        default:
            Options.setSegmentNotification(segment: 0, bool: sender.isOn)
            let tasks = TaskCategory.returnTaskCategory(sender.tag).taskList
            notificationHandler.batchModifyNotifications(tasks: Array(tasks))
            // print("Morning Switch Toggled \(sender.isOn)")
        }
    }

//    @IBOutlet var darkModeSwtich: UISwitch!
//    @IBAction func darkModeSwitchToggled(_ sender: UISwitch) {
//        Options.setDarkMode(sender.isOn)
//        // setAppearance(forSegment: Options.getSelectedIndex())
//    }

    // MARK: Task Priorities

//    @IBOutlet var taskPrioritiesLabel: UILabel!
//    @IBOutlet var taskPrioritiesStatusLabel: UILabel!
//    @IBOutlet var taskPrioritiesCell: UITableViewCell!

    // MARK: Unlock and Restore Purchase

//    @IBOutlet var unlockCell: UITableViewCell!
//    @IBOutlet var unlockButton: UIButton!
//    @IBAction func unlockButtonAction(_: UIButton) {
//        if !RoutinesPlus.getPurchasedStatus() {
//            segueToRoutinesPlusViewController()
//        }
//    }
//
//    @IBOutlet var restorePurchaseCell: UITableViewCell!
//    @IBOutlet var restorePurchaseButton: UIButton!
//    @IBAction func restorePurchaseButtonAction(_: UIButton) {
//        restorePurchase()
//    }

    // MARK: - View management

    @objc func dismissView() {
        // dismiss(animated: true, completion: nil)
//        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
        self.dismiss(animated: true, completion: nil)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        debugPrint("Segue")
//        if let taskView = segue.destination as? TaskTableViewController {
//            // KVO, all the built in lifecycle functions, and this completely fail
//            debugPrint("Reloading table after unloading options view")
//            taskView.tableView.reloadData()
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Colors
//        cellLabels.forEach { label in
//            label.theme_textColor = GlobalPicker.cellTextColors
//        }
        switches.forEach { UISwitch in
            // band-aid for graphical glitch when toggling dark mode
            UISwitch.layer.cornerRadius = 15
            UISwitch.layer.masksToBounds = true
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissView))

//        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        observeOptions()
//        observeRoutinesPlus()
        
        setUpUI(animated: false)
    }

//    override func applicationFinishedRestoringState() {
//        TaskTableViewController.setAppearance(forSegment: Options.getSelectedIndex())
//    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // setUpUI(animated: false)
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }

    // Make the full width of the cell toggle the switch along with typical haptic
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        switch indexPath.section {
        case 1:
            notificationHandler.checkNotificationPermission()
            switch indexPath.row {
            case 1:
                // print("Tapped Afternoon Cell")
                let isOn = !afternoonSwitch.isOn
                afternoonSwitch.setOn(isOn, animated: true)
                haptic.impactOccurred()
                // The next line should not be necessary. iOS 13 bug/regression
                Options.setSegmentNotification(segment: 1, bool: afternoonSwitch.isOn)
                let tasks = TaskCategory.returnTaskCategory(1).taskList
                notificationHandler.batchModifyNotifications(tasks: Array(tasks))
            case 2:
                // print("Tapped Evening Cell")
                let isOn = !eveningSwitch.isOn
                eveningSwitch.setOn(isOn, animated: true)
                haptic.impactOccurred()
                // The next line should not be necessary. iOS 13 bug/regression
                Options.setSegmentNotification(segment: 2, bool: eveningSwitch.isOn)
                let tasks = TaskCategory.returnTaskCategory(2).taskList
                notificationHandler.batchModifyNotifications(tasks: Array(tasks))
            case 3:
                // print("Tapped Night Cell")
                let isOn = !nightSwitch.isOn
                nightSwitch.setOn(isOn, animated: true)
                haptic.impactOccurred()
                // The next line should not be necessary. iOS 13 bug/regression
                Options.setSegmentNotification(segment: 3, bool: nightSwitch.isOn)
                let tasks = TaskCategory.returnTaskCategory(3).taskList
                notificationHandler.batchModifyNotifications(tasks: Array(tasks))
            default:
                // print("Tapped Morning Cell")
                let isOn = !morningSwitch.isOn
                morningSwitch.setOn(isOn, animated: true)
                haptic.impactOccurred()
                // The next line should not be necessary. iOS 13 bug/regression
                Options.setSegmentNotification(segment: 0, bool: morningSwitch.isOn)
                let tasks = TaskCategory.returnTaskCategory(0).taskList
                notificationHandler.batchModifyNotifications(tasks: Array(tasks))
            }
        default:
            debugPrint("\(#function) - Default case triggered")
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Set when each time period should begin"
        case 1:
            return "Enable to receive notifications at the start of each period"
        default:
            return nil
        }
    }

    func setUpUI(animated: Bool) {
        UISwitch.appearance().onTintColor = UIColor(segment: selectedIndex ?? Options.getSelectedIndex())
        navigationController?.navigationBar.tintColor = UIColor(segment: selectedIndex ?? Options.getSelectedIndex())
        
        morningSwitch.setOn(Options.getSegmentNotification(segment: 0), animated: animated)
        afternoonSwitch.setOn(Options.getSegmentNotification(segment: 1), animated: animated)
        eveningSwitch.setOn(Options.getSegmentNotification(segment: 2), animated: animated)
        nightSwitch.setOn(Options.getSegmentNotification(segment: 3), animated: animated)

//        let realm = try! Realm()
//        let routinesPlus = realm.object(ofType: RoutinesPlus.self, forPrimaryKey: RoutinesPlus.primaryKey())

//        cloudSyncSwitch.setOn(routinesPlus?.getCloudSync() ?? false, animated: animated)
//        cloudSyncSwitch.isEnabled = RoutinesPlus.getPurchasedStatus()

//        darkModeSwtich.setOn(Options.getDarkModeStatus(), animated: animated)
//        darkModeSwtich.isEnabled = !Options.getAutomaticDarkModeStatus()

//        switch Options.getAutomaticDarkModeStatus() {
//        case true:
//            automaticDarkModeStatusLabel.text = "Enabled"
        ////            automaticDarkModeStatusLabel.theme_textColor = GlobalPicker.textColor
//        case false:
//            automaticDarkModeStatusLabel.text = "Disabled"
//            automaticDarkModeStatusLabel.textColor = .lightGray
//        }

//        taskPrioritiesLabel.theme_textColor = GlobalPicker.cellTextColors
//        upcomingTasksSwitch.setOn(RoutinesPlus.getShowUpcomingTasks(), animated: animated)

//        unlockButton.layer.masksToBounds = true
//        unlockButton.layer.cornerRadius = 12

//        if RoutinesPlus.getPurchasedStatus() {
//            taskPrioritiesStatusLabel.text = "Unlocked"
//            taskPrioritiesStatusLabel.theme_textColor = GlobalPicker.textColor
//            taskPrioritiesCell.accessoryType = .none

//            upcomingTasksSwitch.isEnabled = true
//            upcomingTasksCellStatusLabel.text = "Unlocked"
//            upcomingTasksCellStatusLabel.theme_textColor = GlobalPicker.textColor

//            unlockButton.isEnabled = false
//            unlockButton.theme_backgroundColor = GlobalPicker.backgroundColor
//            unlockButton.layer.theme_borderColor = GlobalPicker.shadowColor
//            unlockButton.layer.borderWidth = 2
//        } else {
//            taskPrioritiesStatusLabel.text = "Disabled"
//            taskPrioritiesStatusLabel.textColor = .lightGray
//            taskPrioritiesCell.accessoryType = .disclosureIndicator
//
//            upcomingTasksSwitch.isEnabled = false
//            upcomingTasksCellStatusLabel.text = "Disabled"
//            upcomingTasksCellStatusLabel.textColor = .lightGray
//
//            unlockButton.isEnabled = true
//            unlockButton.theme_backgroundColor = GlobalPicker.barTextColor
//            unlockButton.layer.borderWidth = 0
//        }

//        unlockButton.setTitle("Unlock", for: .normal)
//        unlockButton.setTitle("Unlocked", for: .disabled)

//        unlockButton.setTitleColor(.white, for: .normal)
//        unlockButton.theme_setTitleColor(GlobalPicker.barTextColor, forState: .disabled)

//        restorePurchaseButton.theme_setTitleColor(GlobalPicker.cellTextColors, forState: .normal)

        morningSubLabel.text = Options.getSegmentTimeString(segment: 0)
        afternoonSubLabel.text = Options.getSegmentTimeString(segment: 1)
        eveningSubLabel.text = Options.getSegmentTimeString(segment: 2)
        nightSubLabel.text = Options.getSegmentTimeString(segment: 3)
    }

    func refreshUI() {
        DispatchQueue.main.async {
            self.setUpUI(animated: true)
        }
    }

//    func setAppearance(tab: Int) {
//        if Options.getDarkModeStatus() {
//            switch tab {
//            case 1:
//                Themes.switchTo(theme: .afternoonDark)
//            case 2:
//                Themes.switchTo(theme: .eveningDark)
//            case 3:
//                Themes.switchTo(theme: .nightDark)
//            default:
//                Themes.switchTo(theme: .morningDark)
//            }
//        } else {
//            switch tab {
//            case 1:
//                Themes.switchTo(theme: .afternoonLight)
//            case 2:
//                Themes.switchTo(theme: .eveningLight)
//            case 3:
//                Themes.switchTo(theme: .nightLight)
//            default:
//                Themes.switchTo(theme: .morningLight)
//            }
//        }
//    }

    // MARK: - Options

    var optionsToken: NotificationToken?
//    var routinesPlusToken: NotificationToken?

//    var pleaseWaitAlert: SwiftMessagesAlertsController?
//    @objc private func dismissWaitAlert() {
//        guard pleaseWaitAlert != nil else { return }
//        pleaseWaitAlert?.dismissAlert()
//        pleaseWaitAlert = nil
//        Task.requestNotificationPermission()
//    }

    deinit {
        debugPrint("\(#function) called from OptionsTableViewController. Options token invalidated")
        optionsToken?.invalidate()
//        routinesPlusToken?.invalidate()
//        pleaseWaitAlert = nil
    }

    // Need to observe all options even though there will really only be one object because sometimes that object may need to be deleted
    func observeOptions() {
        if let realm = try? Realm() {
            let optionsList = realm.objects(Options.self)
            optionsToken = optionsList.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                switch changes {
                case .initial:
                    debugPrint("Initial load for Options. Set up UI")
//                    self.setUpUI(animated: false)
                case .update:
                    // Don't bother taking action of Options don't even exist
                    self.refreshUI()
                case let .error(error):
                    // An error occurred while opening the Realm file on the background worker thread
                    debugPrint("\(error)")
                }
            }
        }
    }
}
