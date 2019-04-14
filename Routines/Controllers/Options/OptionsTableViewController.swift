//
//  OptionsTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import SwiftTheme
import UIKit
import UserNotifications
// import UserNotificationsUI

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

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "w", modifierFlags: .init(arrayLiteral: .command), action: #selector(dismissView), discoverabilityTitle: "Exit"),
        ]
    }

    @IBAction func notificationSwitchToggled(_: UISwitch) {
//        switch sender.tag {
//        case 1:
//            // print("Afternoon Switch Toggled \(sender.isOn)")
//            addOrRemoveNotifications(isOn: sender.isOn, segment: 1)
//            updateNotificationOptions(segment: 1, isOn: sender.isOn)
//        case 2:
//            // print("Evening Switch Toggled \(sender.isOn)")
//            addOrRemoveNotifications(isOn: sender.isOn, segment: 2)
//            updateNotificationOptions(segment: 2, isOn: sender.isOn)
//        case 3:
//            // print("Night Switch Toggled \(sender.isOn)")
//            addOrRemoveNotifications(isOn: sender.isOn, segment: 3)
//            updateNotificationOptions(segment: 3, isOn: sender.isOn)
//        default:
//            // print("Morning Switch Toggled \(sender.isOn)")
//            addOrRemoveNotifications(isOn: sender.isOn, segment: 0)
//            updateNotificationOptions(segment: 0, isOn: sender.isOn)
//        }
    }

    @IBOutlet var darkModeSwtich: UISwitch!
    @IBAction func darkModeSwitchToggled(_ sender: UISwitch) {
        saveDarkModeOption(isOn: sender.isOn)
    }

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
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1:
                // print("Tapped Afternoon Cell")
                let isOn = !afternoonSwitch.isOn
                afternoonSwitch.setOn(isOn, animated: true)
//                addOrRemoveNotifications(isOn: isOn, segment: 1)
//                // print("Afternoon switch is now set to: \(afternoonSwitch.isOn)")
//                updateNotificationOptions(segment: 1, isOn: afternoonSwitch.isOn)
                haptic.impactOccurred()
            case 2:
                // print("Tapped Evening Cell")
                let isOn = !eveningSwitch.isOn
                eveningSwitch.setOn(isOn, animated: true)
//                addOrRemoveNotifications(isOn: isOn, segment: 2)
//                // print("Evening switch is now set to: \(eveningSwitch.isOn)")
//                updateNotificationOptions(segment: 2, isOn: eveningSwitch.isOn)
                haptic.impactOccurred()
            case 3:
                // print("Tapped Night Cell")
                let isOn = !nightSwitch.isOn
                nightSwitch.setOn(isOn, animated: true)
//                addOrRemoveNotifications(isOn: isOn, segment: 3)
//                // print("Night switch is now set to: \(nightSwitch.isOn)")
//                updateNotificationOptions(segment: 3, isOn: nightSwitch.isOn)
                haptic.impactOccurred()
            default:
                // print("Tapped Morning Cell")
                let isOn = !morningSwitch.isOn
                morningSwitch.setOn(isOn, animated: true)
//                addOrRemoveNotifications(isOn: isOn, segment: 0)
//                // print("Morning switch is now set to: \(morningSwitch.isOn)")
//                updateNotificationOptions(segment: 0, isOn: morningSwitch.isOn)
                haptic.impactOccurred()
            }
        }

        if indexPath.section == 2 {
            darkModeSwtich.setOn(!darkModeSwtich.isOn, animated: true)
            saveDarkModeOption(isOn: darkModeSwtich.isOn)
            haptic.impactOccurred()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            tableView.estimatedRowHeight = 60
            return UITableView.automaticDimension
        } else {
            return 60
        }
    }

    // MARK: - Options Realm

//    func updateNotificationOptions(segment: Int, isOn: Bool) {
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
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
        DispatchQueue.main.async {
            autoreleasepool {
                self.morningSwitch.setOn(self.getSegmentNotificationOption(segment: 0), animated: false)
                self.afternoonSwitch.setOn(self.getSegmentNotificationOption(segment: 1), animated: false)
                self.eveningSwitch.setOn(self.getSegmentNotificationOption(segment: 2), animated: false)
                self.nightSwitch.setOn(self.getSegmentNotificationOption(segment: 3), animated: false)

                self.darkModeSwtich.setOn(self.getDarkModeStatus(), animated: false)

                self.morningSubLabel.text = self.getOptionTimes(timePeriod: 0)
                self.afternoonSubLabel.text = self.getOptionTimes(timePeriod: 1)
                self.eveningSubLabel.text = self.getOptionTimes(timePeriod: 2)
                self.nightSubLabel.text = self.getOptionTimes(timePeriod: 3)
            }
        }
    }

    open func getSegmentNotificationOption(segment: Int) -> Bool {
        var isOn = true
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    if let on = options?.afternoonNotificationsOn {
                        isOn = on
                    }
                case 2:
                    if let on = options?.eveningNotificationsOn {
                        isOn = on
                    }
                case 3:
                    if let on = options?.nightNotificationsOn {
                        isOn = on
                    }
                default:
                    if let on = options?.morningNotificationsOn {
                        isOn = on
                    }
                }
            }
        }
        return isOn
    }

    func getNotificationBool(notificationOption: Bool?) -> Bool {
        var isOn = true
        if let notificationIsOn = notificationOption {
            isOn = notificationIsOn
        }
        return isOn
    }

    func getOptionTimes(timePeriod: Int) -> String {
        var time: String = " "
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                var timeOption = DateComponents()
                timeOption.calendar = Calendar.autoupdatingCurrent
                timeOption.timeZone = TimeZone.autoupdatingCurrent

                switch timePeriod {
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

                let periods = ["morning", "afternoon", "evening", "night"]
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                dateFormatter.locale = Locale.autoupdatingCurrent
                dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
                // print("timeOption DateComponents: \(String(describing: timeOption))")

                time = "Your \(periods[timePeriod]) begins at \(DateFormatter.localizedString(from: timeOption.date!, dateStyle: .none, timeStyle: .short))"
            }
        }

        return time
    }

    func getOptionTimesAsDate(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short

        if let setTime = timeOption {
            time = setTime
        } else {
            time = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
        }

        return time
    }

//
//    func getHour(date: Date) -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH"
//        let hour = dateFormatter.string(from: date)
//        return Int(hour)!
//    }
//
//    func getMinute(date: Date) -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "mm"
//        let minutes = dateFormatter.string(from: date)
//        return Int(minutes)!
//    }

//    func updateItemUUID(item: Item, uuidString: String) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                do {
//                    try realm.write {
//                        item.uuidString = uuidString
//                    }
//                } catch {
//                    // print("updateItemUUID failed")
//                }
//            }
//        }
//    }

    // MARK: - Manage Notifications

//    func enableNotificationsForSegment(segment: Int) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                let items = realm.objects(Items.self).filter("segment = \(segment) AND isDeleted = \(false)")
//                items.forEach { item in
//                    item.createNotification()
//                }
//            }
//        }
//    }
//
//    func removeNotificationsForSegment(segment: Int) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                let items = realm.objects(Items.self).filter("segment = \(segment) AND isDeleted = \(false)")
//                items.forEach { item in
//                    item.removeNotification()
//                }
//            }
//        }
//    }
//
//    open func addOrRemoveNotifications(isOn: Bool, segment: Int) {
//        if isOn {
//            enableNotificationsForSegment(segment: segment)
//        } else {
//            removeNotificationsForSegment(segment: segment)
//        }
//    }

    // MARK: - Conversion functions

    let defaultTimeStrings = ["07:00", "12:00", "17:00", "21:00"]

    func getLocalTimeString(date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }

    func getTime(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let dateFormatter = DateFormatter()
        // dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
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

    func getOptionHour(segment: Int) -> Int {
        var hour = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    hour = (options?.afternoonHour)!
                case 2:
                    hour = (options?.eveningHour)!
                case 3:
                    hour = (options?.nightHour)!
                default:
                    hour = (options?.morningHour)!
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

    // Set the notification badge count
    func getSegmentCount(segment: Int) -> Int {
        var count = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Items.self).filter("segment = \(segment)").count
            }
        }
        return count
    }

    // MARK: - Realm

    let realmDispatchQueueLabel: String = "background"
    let optionsKey = "optionsKey"

    lazy var morningHour: Int = 7
    lazy var morningMinute: Int = 0

    lazy var afternoonHour: Int = 12
    lazy var afternoonMinute: Int = 0

    lazy var eveningHour: Int = 17
    lazy var eveningMinute: Int = 0

    lazy var nightHour: Int = 21
    lazy var nightMinute: Int = 0

    // Load Options
    func loadOptions() {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    self.morningHour = options.morningHour
                    self.morningMinute = options.morningMinute

                    self.afternoonHour = options.afternoonHour
                    self.afternoonMinute = options.afternoonMinute

                    self.eveningHour = options.eveningHour
                    self.eveningMinute = options.eveningMinute

                    self.nightHour = options.nightHour
                    self.nightMinute = options.nightMinute
                }
            }
        }
    }

    public func getSegmentNotification(segment: Int) -> Bool {
        var enabled = false
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
                    switch segment {
                    case 1:
                        enabled = options.afternoonNotificationsOn
                    case 2:
                        enabled = options.eveningNotificationsOn
                    case 3:
                        enabled = options.nightNotificationsOn
                    default:
                        enabled = options.morningNotificationsOn
                    }
                }
            }
        }
        return enabled
    }

    // MARK: - Themeing

    func saveDarkModeOption(isOn: Bool) {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    do {
                        try realm.write {
                            options.darkMode = isOn
                        }
                    } catch {
                        // print("failed to update dark mode")
                    }
                }
            }
        }
        setAppearance(tab: getSelectedTab())
    }

    func getDarkModeStatus() -> Bool {
        var darkMode = true
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

    func getSelectedTab() -> Int {
        var selectedIndex = 0
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    selectedIndex = options.selectedIndex
                }
            }
        }
        return selectedIndex
    }

    func setAppearance(tab: Int) {
        if getDarkModeStatus() {
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
}
