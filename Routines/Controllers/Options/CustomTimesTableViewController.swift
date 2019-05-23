//
//  CustomTimesTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

// TODO: You need to fetch uuidStrings on all current items and modify their associated notifications to match any updated times. Run those updates in async. It could be many.

import RealmSwift
import UIKit
import UserNotifications

class CustomTimesTableViewController: UITableViewController {
    @IBOutlet var morningDatePicker: UIDatePicker!
    @IBOutlet var afternoonDatePicker: UIDatePicker!
    @IBOutlet var eveningDatePicker: UIDatePicker!
    @IBOutlet var nightDatePicker: UIDatePicker!

    @IBOutlet var datePickers: [UIDatePicker]!

    @IBAction func morningTimeSet(_: UIDatePicker) {
        updateSavedTimes(segment: 0, hour: getHour(date: morningDatePicker.date), minute: getMinute(date: morningDatePicker.date))
    }

    @IBAction func afternoonTimeSet(_: UIDatePicker) {
        updateSavedTimes(segment: 1, hour: getHour(date: afternoonDatePicker.date), minute: getMinute(date: afternoonDatePicker.date))
    }

    @IBAction func eveningTimeSet(_: UIDatePicker) {
        updateSavedTimes(segment: 2, hour: getHour(date: eveningDatePicker.date), minute: getMinute(date: eveningDatePicker.date))
    }

    @IBAction func nightTimeSet(_: UIDatePicker) {
        updateSavedTimes(segment: 3, hour: getHour(date: nightDatePicker.date), minute: getMinute(date: nightDatePicker.date))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        datePickers.forEach { picker in
            // We can't assign a color directly to the date picker
            // But we can assign it to text that doesn't exist and then fetch the color from that
            let text = UILabel()
            text.theme_textColor = GlobalPicker.cellTextColors
            // Get color
            let textColor = text.textColor
            // Assign color
            picker.setValue(textColor, forKeyPath: "textColor")
        }
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(displayResetAction))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpUI(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // keep saved times updated with what's shown in UI
        saveAllTimes()
    }

    override func viewWillDisappear(_: Bool) {
        saveAllTimes()
    }

    @objc func displayResetAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Reset Times to Default", style: .destructive, handler: { _ in
            self.resetTimes()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func resetTimes() {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let newOptions = Options()
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
                do {
                    try realm.write {
                        options?.morningHour = newOptions.morningHour
                        options?.morningMinute = newOptions.morningMinute
                        options?.afternoonHour = newOptions.afternoonHour
                        options?.afternoonMinute = newOptions.afternoonMinute
                        options?.eveningHour = newOptions.eveningHour
                        options?.eveningMinute = newOptions.eveningMinute
                        options?.nightHour = newOptions.nightHour
                        options?.nightMinute = newOptions.nightMinute
                    }
                } catch {
                    fatalError("Error resetting times: \(error)")
                }
            }
        }
        setUpUI(animated: true)
    }

    // Save all times
    func saveAllTimes() {
        let datePickerArray: [UIDatePicker] = [morningDatePicker, afternoonDatePicker, eveningDatePicker, nightDatePicker]
        updateSavedTimes(segment: 0, hour: getHour(date: datePickerArray[0].date), minute: getMinute(date: datePickerArray[0].date))
        updateSavedTimes(segment: 1, hour: getHour(date: datePickerArray[1].date), minute: getMinute(date: datePickerArray[1].date))
        updateSavedTimes(segment: 2, hour: getHour(date: datePickerArray[2].date), minute: getMinute(date: datePickerArray[2].date))
        updateSavedTimes(segment: 3, hour: getHour(date: datePickerArray[3].date), minute: getMinute(date: datePickerArray[3].date))
    }

    // MARK: - Options Realm

    func updateSavedTimes(segment: Int, hour: Int, minute: Int) {
        // print("updateSavedTimes received: Hour - \(hour), minute - \(minute)")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
                do {
                    try realm.write {
                        switch segment {
                        case 1:
                            options?.afternoonHour = hour
                            options?.afternoonMinute = minute
                        case 2:
                            options?.eveningHour = hour
                            options?.eveningMinute = minute
                        case 3:
                            options?.nightHour = hour
                            options?.nightMinute = minute
                        default:
                            options?.morningHour = hour
                            options?.morningMinute = minute
                        }
                    }
                } catch {
                    // print("updateSavedTimes failed")
                }
            }
        }
    }

    func setUpUI(animated: Bool) {
        if let morningTime = getTimesFromOptions(segment: 0) {
            morningDatePicker.setDate(morningTime, animated: animated)
        }
        if let afternoonTime = getTimesFromOptions(segment: 1) {
            afternoonDatePicker.setDate(afternoonTime, animated: animated)
        }
        if let eveningTime = getTimesFromOptions(segment: 2) {
            eveningDatePicker.setDate(eveningTime, animated: animated)
        }
        if let nightTime = getTimesFromOptions(segment: 3) {
            nightDatePicker.setDate(nightTime, animated: animated)
        }
    }

    func getTimesFromOptions(segment: Int) -> Date? {
        var date: Date?
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    // let dateFormatter = DateFormatter()

                    switch segment {
                    case 1:
                        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, hour: options.afternoonHour, minute: options.afternoonMinute)
                        date = dateComponents.date!
                    case 2:
                        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, hour: options.eveningHour, minute: options.eveningMinute)
                        date = dateComponents.date!
                    case 3:
                        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, hour: options.nightHour, minute: options.nightMinute)
                        date = dateComponents.date!
                    default:
                        let dateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, hour: options.morningHour, minute: options.morningMinute)
                        date = dateComponents.date!
                    }
                }
            }
        }
        return date
    }

    // MARK: - Conversion functions

    func getTime(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let defaultTimeStrings = ["07:00 AM", "12:00 PM", "5:00 PM", "9:00 PM"]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short

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
                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
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
                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
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
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
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

    func getSegmentNotification(segment: Int) -> Bool {
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

//    func getSelectedTab() -> Int {
//        var selectedIndex = 0
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                    selectedIndex = options.selectedIndex
//                }
//            }
//        }
//        return selectedIndex
//    }
//
//    func getDarkModeStatus() -> Bool {
//        var darkMode = false
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                    darkMode = options.darkMode
//                }
//            }
//        }
//        return darkMode
//    }
}
