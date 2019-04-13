//
//  AddTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/23/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import SwiftMessages
import UIKit
import UserNotifications

class AddTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {
    // MARK: - Properties

    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var segmentSelection: UISegmentedControl!
    @IBOutlet var notesTextView: UITextView!

    @IBOutlet var repeatDailySwitch: UISwitch!
    @IBAction func repeatDailySwitchToggled(_: UISwitch) {
        if item != nil {
            showBanner(title: "Repeat Option Saved")
            // print("repeat toggled to \(sender.isOn)")
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "s", modifierFlags: .command, action: #selector(saveKeyCommand), discoverabilityTitle: "Save Task"),
            UIKeyCommand(input: "w", modifierFlags: .init(arrayLiteral: .command), action: #selector(dismissView), discoverabilityTitle: "Exit"),
        ]
    }

    @objc func saveKeyCommand() {
        // TODO: If the user tries to save before they're able, show a helpful banner message
        if navigationItem.rightBarButtonItem!.isEnabled {
            saveButtonPressed()
        }
    }

    @IBOutlet var repeatDailyLabel: UILabel!

    // @IBOutlet var cells: [UITableViewCell]!

    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        setAppearance(segment: sender.selectedSegmentIndex)
    }

//    @IBOutlet weak var repeatLabel: UILabel!
//    @IBOutlet weak var repeatHowOftenLabel: UILabel!
//    @IBOutlet var repeatCellTitleLabel: UILabel!
//    @IBOutlet var repeatCellDetailLabel: UILabel!

    //let realmDispatchQueueLabel: String = "background"

    var item: Items?
    // var timeArray: [DateComponents?] = []
    // segment from add segue
    var editingSegment: Int?
    // var segue: UIStoryboardSegue?

    fileprivate func setUpUI() {
        if item != nil {
            setAppearance(segment: item!.segment)
        }
        repeatDailySwitch.layer.cornerRadius = 15
        repeatDailySwitch.layer.masksToBounds = true

        repeatDailyLabel.theme_textColor = GlobalPicker.cellTextColors
    }

    @objc func dismissView() {
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            autoreleasepool {
                do {
                    self.taskTextField.becomeFirstResponder()

                    self.setUpUI()
                }
            }
        }

        // Set right bar item as "Save"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
        // Disable button until all values are filled
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissView))

        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
//        cells.forEach { (cell) in
//            cell.theme_backgroundColor = GlobalPicker.backgroundColor
//        }
        let cellAppearance = UITableViewCell.appearance()
        cellAppearance.theme_backgroundColor = GlobalPicker.backgroundColor

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }

        // self.tabBarController?.tabBar.isHidden = true
        // If item is loaded, fill in values for editing
        if item != nil {
            // print("item was non-nil")
            taskTextField.text = item?.title
            segmentSelection.selectedSegmentIndex = item?.segment ?? 0
            notesTextView.text = item?.notes
            // // print("Items's uuidString is \((item?.uuidString)!)")
            // repeatDailySwitch.setOn(item?.disableAutoSnooze ?? false, animated: false)

            title = "Edit Task"
        } else {
            title = "Add New Task"
        }

        // load in segment from add segue
        if let currentSegmentSelection = editingSegment {
            segmentSelection.selectedSegmentIndex = currentSegmentSelection
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        taskTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        segmentSelection.addTarget(self, action: #selector(textFieldDidChange), for: .valueChanged)
        notesTextView.delegate = self
        taskTextField.delegate = self

        notesTextView.layer.cornerRadius = 6
        notesTextView.layer.masksToBounds = true
        notesTextView.layer.borderWidth = 0.1
        notesTextView.layer.borderColor = UIColor.darkGray.cgColor

        if taskTextField.hasText == false {
            //taskTextField.backgroundColor = UIColor.groupTableViewBackground
        }

        if notesTextView.hasText == false {
            // notesTextView.backgroundColor = UIColor.groupTableViewBackground
        }

        // Add tap gesture for editing notes
        let textFieldTap = UITapGestureRecognizer(target: self, action: #selector(setNotesEditable))
        notesTextView.addGestureRecognizer(textFieldTap)

        // add a tap recognizer to stop editing when tapping outside the textView
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        viewTap.cancelsTouchesInView = false
        view.addGestureRecognizer(viewTap)

        taskTextField.theme_keyboardAppearance = GlobalPicker.keyboardStyle
        taskTextField.theme_textColor = GlobalPicker.cellTextColors
        taskTextField.theme_backgroundColor = GlobalPicker.textInputBackground

        notesTextView.theme_keyboardAppearance = GlobalPicker.keyboardStyle
        notesTextView.theme_textColor = GlobalPicker.cellTextColors
        notesTextView.theme_backgroundColor = GlobalPicker.textInputBackground
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }

    @objc func setNotesEditable(_: UITapGestureRecognizer) {
        notesTextView.dataDetectorTypes = []
        notesTextView.isEditable = true
        notesTextView.becomeFirstResponder()

        // notesTextView.backgroundColor = UIColor.groupTableViewBackground
    }

    @objc func viewTapped(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = false
        textView.dataDetectorTypes = .all

        if textView.hasText {
            //textView.backgroundColor = .white
        }
    }

    func textViewDidBeginEditing(_: UITextView) {
        //textView.backgroundColor = UIColor.groupTableViewBackground
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.hasText {
            //textField.backgroundColor = .white
        }
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
            repeatDailySwitch.setOn(!repeatDailySwitch.isOn, animated: true)
            if item != nil {
                navigationItem.rightBarButtonItem?.isEnabled = true
                updateItem()
                showBanner(title: "Repeat Option Saved")
                // print("repeat toggled to \(repeatDailySwitch.isOn)")
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if let destinationVC = segue.destination as? TableViewController {
//            destinationVC.setSegment = segmentSelection.selectedSegmentIndex
//        }
//    }

//    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
//        if let destination = segue.destination as? TableViewController {
//            destination.resetTableView()
//        }
//    }

    @objc func textFieldDidChange() {
        if taskTextField.text!.count > 0 {
            // itemTitle = taskTextField.text!
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            // itemTitle = nil
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    func textViewDidChange(_: UITextView) {
        if item != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    @objc func saveButtonPressed() {
        //TODO: Use the Items convenience init
        addNewItem(title: taskTextField.text!, date: Date(), segment: segmentSelection.selectedSegmentIndex, notes: notesTextView.text)
        // // print("Adding item with uuidString: \(self.uuidString)")
        // self.tabBarController?.tabBar.isHidden = false
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
//        if segue.identifier == "unwindToTableViewController" {
//            let destinationVC = segue.destination as! TableViewController
//            destinationVC.passedSegment = segmentSelection.selectedSegmentIndex
//            destinationVC.changeSegment(segment: segmentSelection.selectedSegmentIndex)
//        }
//        if segue.identifier == "repeatSegue" {}
//    }

    func firstTriggerDate(segment: Int) -> Date {
        let tomorrow = Date().startOfNextDay
        var dateComponents = DateComponents()
        var segmentTime = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: Date())
        segmentTime.hour = getOptionHour(segment: segment)
        segmentTime.minute = getOptionMinute(segment: segment)
        segmentTime.second = 0
        // TODO: This might cause problems
        if Date() > segmentTime.date! {
            // print("Setting item date for tomorrow")
            dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: tomorrow)
        } else {
            // print("Setting item date for today")
            dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .calendar, .timeZone], from: Date())
        }
        dateComponents.hour = getOptionHour(segment: segment)
        dateComponents.minute = getOptionMinute(segment: segment)
        dateComponents.second = 0
        // print("Setting first trigger date for: \(dateComponents)")
        return dateComponents.date!
    }

    func addNewItem(title: String, date _: Date, segment: Int, notes: String) {
        // print("Running addNewItem")
        // if it's a new item, add it as new to the realm
        // otherwise, update the existing item
        if item == nil {
            let newItem = Items()
            newItem.title = title
            newItem.segment = segment
            newItem.dateModified = firstTriggerDate(segment: segment)
            newItem.notes = notes
            // newItem.disableAutoSnooze = repeatDailySwitch.isOn
            // print("new item's uuidString: \(newItem.uuidString)")
            // save to realm
            saveItem(item: newItem)
            if getAutoSnoozeStatus() {
                scheduleAutoSnoozeNotifications(title: title, notes: notes, segment: segment, uuidString: newItem.uuidString, firstDate: newItem.dateModified)
            } else {
                scheduleNewNotification(title: title, notes: notes, segment: segment, uuidString: newItem.uuidString, firstDate: newItem.dateModified)
            }
        } else {
            updateItem()
        }
    }

    func saveItem(item: Items) {
        // print("Running saveItem")
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            // print("Error saving item: \(error)")
        }
    }

    func updateItem() {
        let realm = try! Realm()
        do {
            try realm.write {
                self.item!.title = self.taskTextField.text
                self.item!.segment = self.segmentSelection.selectedSegmentIndex
                self.item!.notes = self.notesTextView.text
                // self.item!.disableAutoSnooze = repeatDailySwitch.isOn
            }
        } catch {
            // print("Error updating item: \(error)")
        }
        removeNotification(uuidString: ["\(self.item!.uuidString)0", "\(self.item!.uuidString)1", "\(self.item!.uuidString)2", "\(self.item!.uuidString)3"])

        if getAutoSnoozeStatus() {
            scheduleAutoSnoozeNotifications(title: item!.title!, notes: item!.notes, segment: item!.segment, uuidString: item!.uuidString, firstDate: item!.dateModified)
        } else {
            scheduleNewNotification(title: item!.title!, notes: item!.notes, segment: item!.segment, uuidString: item!.uuidString, firstDate: item!.dateModified)
        }
    }

    // MARK: - Manage Notifications

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

    // TODO: This is near identical to another function here
    func getSegmentNotificationOption(segment: Int) -> Bool {
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

    func scheduleAutoSnoozeNotifications(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
        // This is where you need to test if a segment is > current segment
        let dayOfFirstDate = Calendar.autoupdatingCurrent.dateComponents([.day], from: firstDate)
        // print("dayOfFirstDate: \(dayOfFirstDate)")
        let today = Calendar.autoupdatingCurrent.dateComponents([.day], from: Date())
        // print("today: \(today)")
        if segment > 0, dayOfFirstDate == today {
            if getSegmentNotificationOption(segment: 0) {
                scheduleNewNotification(title: title, notes: notes, segment: 0, uuidString: "\(uuidString)0", firstDate: firstDate.startOfNextDay)
                // print("morning uuid: " + "\(uuidString)0")
            }
        } else {
            if getSegmentNotificationOption(segment: 0) {
                scheduleNewNotification(title: title, notes: notes, segment: 0, uuidString: "\(uuidString)0", firstDate: firstDate)
                // print("morning uuid: " + "\(uuidString)0")
            }
        }
        if segment > 1, dayOfFirstDate == today {
            if getSegmentNotificationOption(segment: 1) {
                scheduleNewNotification(title: title, notes: notes, segment: 1, uuidString: "\(uuidString)1", firstDate: firstDate.startOfNextDay)
                // print("afternoon uuid: " + "\(uuidString)1")
            }
        } else {
            if getSegmentNotificationOption(segment: 1) {
                scheduleNewNotification(title: title, notes: notes, segment: 1, uuidString: "\(uuidString)1", firstDate: firstDate)
                // print("afternoon uuid: " + "\(uuidString)1")
            }
        }
        if segment > 2, dayOfFirstDate == today {
            if getSegmentNotificationOption(segment: 2) {
                scheduleNewNotification(title: title, notes: notes, segment: 2, uuidString: "\(uuidString)2", firstDate: firstDate.startOfNextDay)
                // print("evening uuid: " + "\(uuidString)2")
            }
        } else {
            if getSegmentNotificationOption(segment: 2) {
                scheduleNewNotification(title: title, notes: notes, segment: 2, uuidString: "\(uuidString)2", firstDate: firstDate)
                // print("evening uuid: " + "\(uuidString)2")
            }
        }
        if getSegmentNotificationOption(segment: 3) {
            scheduleNewNotification(title: title, notes: notes, segment: 3, uuidString: "\(uuidString)3", firstDate: firstDate)
            // print("night uuid: " + "\(uuidString)3")
        }
    }

    func scheduleNewNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
        // print("running scheduleNewNotification")
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getNotificationSettings { settings in
            // DO not schedule notifications if not authorized
            guard settings.authorizationStatus == .authorized else {
                // self.requestNotificationPermission()
                // print("Authorization status has changed to unauthorized for notifications")
                return
            }

            DispatchQueue(label: self.realmDispatchQueueLabel).sync {
                autoreleasepool {
                    let realm = try! Realm()
                    let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                    switch segment {
                    case 1:
                        if (options?.afternoonNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
                        } else {
                            // print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    case 2:
                        if (options?.eveningNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
                        } else {
                            // print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    case 3:
                        if (options?.nightNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
                        } else {
                            // print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    default:
                        if (options?.morningNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
                        } else {
                            // print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    }
                }
            }
        }
    }

    func createNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
        // print("createNotification running")
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.threadIdentifier = String(AppDelegate().getItemSegment(id: uuidString))

        content.badge = NSNumber(integerLiteral: AppDelegate().setBadgeNumber())

        if let notesText = notes {
            content.body = notesText
        }

        // Assign the category (and the associated actions).
        switch segment {
        case 1:
            content.categoryIdentifier = "afternoon"
        case 2:
            content.categoryIdentifier = "evening"
        case 3:
            content.categoryIdentifier = "night"
        default:
            content.categoryIdentifier = "morning"
        }

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.autoupdatingCurrent
        // Keep notifications from occurring too early for tasks created for tomorrow
        dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: firstDate)
        dateComponents.timeZone = TimeZone.autoupdatingCurrent
        dateComponents.hour = getOptionHour(segment: segment)
        dateComponents.minute = getOptionMinute(segment: segment)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the request
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        // Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if error != nil {
                // TODO: handle notification errors
                // print(String(describing: error))
            } else {
                // print("Notification created successfully")
            }
        }
    }

    func removeNotification(uuidString: [String]) {
        // print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidString)
    }

    // MARK: - Options Realm

    // Options Properties
    // var optionsObject: Options?
    // var firstItemAdded: Bool?
    let optionsKey = "optionsKey"

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

    // Smart Snooze
    func getSmartSnoozeStatus() -> Bool {
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
        // print("getCurrentSegmentFromTime: \(currentSegment)")
        return currentSegment
    }

    func getDateFromComponents(hour: Int, minute: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.calendar = Calendar.autoupdatingCurrent
        dateComponent.timeZone = TimeZone.autoupdatingCurrent
        dateComponent.hour = hour
        dateComponent.minute = minute
        return dateComponent.date!
    }

    // MARK: Theme

    public func setAppearance(segment: Int) {
        // print("Setting theme")
        if getDarkModeStatus() {
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

    func getDarkModeStatus() -> Bool {
        var darkMode = false
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

//    func getRepeatString() -> String {
//        if let currentItem = item {
//            let repeatDate = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, era: nil, year: currentItem.year, month: currentItem.month, day: currentItem.day, hour: currentItem.hour, minute: currentItem.minute, second: nil, nanosecond: nil, weekday: currentItem.weekday, weekdayOrdinal: currentItem.weekdayOrdinal, quarter: currentItem.quarter, weekOfMonth: currentItem.weekOfMonth, weekOfYear: currentItem.weekOfYear, yearForWeekOfYear: nil)
//            let formatter = DateComponentsFormatter()
//            return formatter.string(from: repeatDate) ?? ""
//        } else {
//            return ""
//        }
//    }

    // MARK: - Banners

    func showBanner(title: String?) {
        SwiftMessages.pauseBetweenMessages = 0
        SwiftMessages.hideAll()
        SwiftMessages.show { () -> UIView in
            let banner = MessageView.viewFromNib(layout: .statusLine)
            banner.configureTheme(.success)
            banner.configureContent(title: "", body: title ?? "Saved!")
            return banner
        }
    }
}
