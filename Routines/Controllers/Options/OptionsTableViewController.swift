//
//  OptionsTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import StoreKit
import SwiftMessages
import SwiftTheme
import SwiftyStoreKit
import UIKit
import UserNotifications

enum RegisteredPurchase: String {
    case lifetime = "lifetime1"
    case yearly = "routines_plus_yearly"
    case monthly = "routines_plus_monthly"
}

class OptionsTableViewController: UITableViewController {
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

    // MARK: - Routines+

    @IBOutlet var cloudSyncLabel: UILabel!
    @IBOutlet var cloudSyncSwitch: UISwitch!
    @IBAction func cloudSyncSwitchToggled(_ sender: UISwitch) {
        if cloudSyncSwitch.isEnabled {
            // cloudSyncSwitch.setOn(!cloudSyncSwitch.isOn, animated: true)
            Options.setCloudSync(toggle: cloudSyncSwitch.isOn)
            AppDelegate.setSync()
            if cloudSyncSwitch.isOn {
                Items.requestNotificationPermission()
                AppDelegate.refreshNotifications()
            }
        } else {
            // Show Purchase Options
            segueToRoutinesPlusViewController()
        }
        #if DEBUG
            print("Cloud sync switch: \(sender.isOn)")
        #endif
    }

    // MARK: Automatic Dark Mode

    @IBOutlet var automaticDarkModeLabel: UILabel!
    @IBOutlet var automaticDarkModeStatusLabel: UILabel!

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "w", modifierFlags: .init(arrayLiteral: .command), action: #selector(dismissView), discoverabilityTitle: "Exit"),
        ]
    }

    @IBAction func notificationSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            checkNotificationPermission()
        }
        switch sender.tag {
        case 1:
            Options.setSegmentNotification(segment: 1, bool: sender.isOn)
        // print("Afternoon Switch Toggled \(sender.isOn)")
        case 2:
            Options.setSegmentNotification(segment: 2, bool: sender.isOn)
        // print("Evening Switch Toggled \(sender.isOn)")
        case 3:
            Options.setSegmentNotification(segment: 3, bool: sender.isOn)
        // print("Night Switch Toggled \(sender.isOn)")
        default:
            Options.setSegmentNotification(segment: 0, bool: sender.isOn)
            // print("Morning Switch Toggled \(sender.isOn)")
        }
    }

    @IBOutlet var darkModeSwtich: UISwitch!
    @IBAction func darkModeSwitchToggled(_ sender: UISwitch) {
        Options.setDarkMode(sender.isOn)
        setAppearance(tab: Options.getSelectedIndex())
    }

    // MARK: Task Priorities

    @IBOutlet var taskPrioritiesLabel: UILabel!
    @IBOutlet var taskPrioritiesStatusLabel: UILabel!
    @IBOutlet var taskPrioritiesCell: UITableViewCell!

    @objc func dismissView() {
        // dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Colors
        cellLabels.forEach { label in
            label.theme_textColor = GlobalPicker.cellTextColors
        }
        switches.forEach { UISwitch in
            // band-aid for graphical glitch when toggling dark mode
            UISwitch.layer.cornerRadius = 15
            UISwitch.layer.masksToBounds = true
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissView))

        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        observeOptions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // Make the full width of the cell toggle the switch along with typical haptic
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        switch indexPath.section {
        case 1:
            checkNotificationPermission()
            switch indexPath.row {
            case 1:
                // print("Tapped Afternoon Cell")
                let isOn = !afternoonSwitch.isOn
                afternoonSwitch.setOn(isOn, animated: true)
                haptic.impactOccurred()
            case 2:
                // print("Tapped Evening Cell")
                let isOn = !eveningSwitch.isOn
                eveningSwitch.setOn(isOn, animated: true)
                haptic.impactOccurred()
            case 3:
                // print("Tapped Night Cell")
                let isOn = !nightSwitch.isOn
                nightSwitch.setOn(isOn, animated: true)
                haptic.impactOccurred()
            default:
                // print("Tapped Morning Cell")
                let isOn = !morningSwitch.isOn
                morningSwitch.setOn(isOn, animated: true)
                haptic.impactOccurred()
            }
        case 2:
            if darkModeSwtich.isEnabled {
                darkModeSwtich.setOn(!darkModeSwtich.isOn, animated: true)
                Options.setDarkMode(darkModeSwtich.isOn)
                setAppearance(tab: Options.getSelectedIndex())
                haptic.impactOccurred()
            }
        case 3:
            switch indexPath.row {
            case 0:
                #if DEBUG
                    print("\(#function) - Case 3")
                #endif
                if cloudSyncSwitch.isEnabled {
                    #if DEBUG
                        print("\(#function) - cloudSyncSwitch.isEnabled")
                    #endif
                    cloudSyncSwitch.setOn(!cloudSyncSwitch.isOn, animated: true)
                    Options.setCloudSync(toggle: cloudSyncSwitch.isOn)
                    AppDelegate.setSync()
                    haptic.impactOccurred()
                    if cloudSyncSwitch.isOn {
                        Items.requestNotificationPermission()
                        AppDelegate.refreshNotifications()
                    }
                } else {
                    #if DEBUG
                        print("\(#function) - Case 3 else, should show purchase options")
                    #endif
                    segueToRoutinesPlusViewController()
                }
            case 1:
                segueToAutomaticDarkModeTableView()
            case 2:
                if !Options.getPurchasedStatus() {
                    segueToRoutinesPlusViewController()
                }
            default:
                break
            }
        default:
            #if DEBUG
                print("\(#function) - Default case triggered")
            #endif
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Set when each time period should begin"
        case 1:
            return "Enable to receive notifications at the start of each period"
        case 3:
            return "Thanks for your support!"
        default:
            return nil
        }
    }

    // MARK: - Options Realm

//    func updateNotificationOptions(segment: Int, isOn: Bool) {
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
//                switch segment {
//                case 1:
//                    do {
//                        try realm.write {
//                            // print("updateNotificationOptions saving")
//                            options?.afternoonNotificationsOn = isOn
//                        }
//                    } catch {
//                        // print("updateNotificationOptions failed")
//                    }
//                case 2:
//                    do {
//                        try realm.write {
//                            // print("updateNotificationOptions saving")
//                            options?.eveningNotificationsOn = isOn
//                        }
//                    } catch {
//                        // print("updateNotificationOptions failed")
//                    }
//                case 3:
//                    do {
//                        try realm.write {
//                            // print("updateNotificationOptions saving")
//                            options?.nightNotificationsOn = isOn
//                        }
//                    } catch {
//                        // print("updateNotificationOptions failed")
//                    }
//                default:
//                    do {
//                        try realm.write {
//                            // print("updateNotificationOptions saving")
//                            options?.morningNotificationsOn = isOn
//                        }
//                    } catch {
//                        // print("updateNotificationOptions failed")
//                    }
//                }
//            }
//        }
//    }

    func setUpUI() {
        morningSwitch.setOn(Options.getSegmentNotification(segment: 0), animated: true)
        afternoonSwitch.setOn(Options.getSegmentNotification(segment: 1), animated: true)
        eveningSwitch.setOn(Options.getSegmentNotification(segment: 2), animated: true)
        nightSwitch.setOn(Options.getSegmentNotification(segment: 3), animated: true)

        cloudSyncSwitch.setOn(Options.getCloudSync(), animated: true)
//        cloudSyncSwitch.isEnabled = Options.getPurchasedStatus()

        darkModeSwtich.setOn(Options.getDarkModeStatus(), animated: true)
        darkModeSwtich.isEnabled = !Options.getAutomaticDarkModeStatus()

        switch Options.getAutomaticDarkModeStatus() {
        case true:
            automaticDarkModeStatusLabel.text = "Enabled"
            automaticDarkModeStatusLabel.theme_textColor = GlobalPicker.textColor
        case false:
            automaticDarkModeStatusLabel.text = "Disabled"
            automaticDarkModeStatusLabel.textColor = .lightGray
        }

        taskPrioritiesLabel.theme_textColor = GlobalPicker.cellTextColors

        taskPrioritiesStatusLabel.text = "Unlocked"
        taskPrioritiesStatusLabel.theme_textColor = GlobalPicker.textColor
        taskPrioritiesCell.accessoryType = .none

        morningSubLabel.text = Options.getSegmentTimeString(segment: 0)
        afternoonSubLabel.text = Options.getSegmentTimeString(segment: 1)
        eveningSubLabel.text = Options.getSegmentTimeString(segment: 2)
        nightSubLabel.text = Options.getSegmentTimeString(segment: 3)
    }

    func refreshUI() {
        // TODO: Refactor this. Just bad
        setUpUI()
    }

    func setAppearance(tab: Int) {
        if Options.getDarkModeStatus() {
            switch tab {
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
            switch tab {
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

    // MARK: - Options

    var optionsToken: NotificationToken?

    deinit {
        optionsToken?.invalidate()
    }

    func observeOptions() {
        let realm = try! Realm()
        if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
            optionsToken = options.observe { change in
                switch change {
                case let .change(properties):
                    properties.forEach { _ in
                        self.refreshUI()
                    }
                // AppDelegate.refreshNotifications()
                case let .error(error):
                    #if DEBUG
                        print("Options observation error occurred: \(error)")
                    #endif
                case .deleted:
                    #if DEBUG
                        print("The object was deleted.")
                    #endif
                }
            }
        }
    }

    // MARK: - IAP

    func segueToAutomaticDarkModeTableView() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let AutomaticDarkModeTableViewController = storyBoard.instantiateViewController(withIdentifier: "AutomaticDarkModeTableView") as! AutomaticDarkModeTableViewController
        navigationController?.pushViewController(AutomaticDarkModeTableViewController, animated: true)
    }
}
