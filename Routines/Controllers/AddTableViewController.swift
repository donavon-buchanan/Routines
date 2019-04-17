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
        if item != nil, taskTextField.hasText {
            navigationItem.rightBarButtonItem?.isEnabled = true
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

    // let realmDispatchQueueLabel: String = "background"

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
            repeatDailySwitch.setOn(item!.repeats, animated: false)
            // // print("Items's uuidString is \((item?.uuidString)!)")
            // repeatDailySwitch.setOn(item?.disableAutoSnooze ?? false, animated: false)

            title = "Editing Task"
        } else {
            title = "Adding New Task"
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
            if item != nil, taskTextField.hasText {
                navigationItem.rightBarButtonItem?.isEnabled = true
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
//            destination.loadItems()
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
        if let updatedItem = item {
            updatedItem.updateItem(title: taskTextField.text!, segment: segmentSelection.selectedSegmentIndex, repeats: repeatDailySwitch.isOn, notes: notesTextView.text)
        } else {
            let realm = try! Realm()
            do {
                try realm.write {
                    let newItem = Items()
                    newItem.title = taskTextField.text!
                    newItem.segment = segmentSelection.selectedSegmentIndex
                    newItem.repeats = repeatDailySwitch.isOn
                    newItem.notes = notesTextView.text
                    realm.add(newItem)
                }
            } catch {
                fatalError("\(#function): failed to add new item")
            }
        }
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }

//    func scheduleNewNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
//        // print("running scheduleNewNotification")
//        let notificationCenter = UNUserNotificationCenter.current()
//
//        notificationCenter.getNotificationSettings { settings in
//            // DO not schedule notifications if not authorized
//            guard settings.authorizationStatus == .authorized else {
//                // self.requestNotificationPermission()
//                // print("Authorization status has changed to unauthorized for notifications")
//                return
//            }
//
//            switch segment {
//            case 1:
//                if (Options.getSegmentNotification(segment: 1)) {
//                    self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//                } else {
//                    return
//                }
//            case 2:
//                if (Options.getSegmentNotification(segment: 2)) {
//                    self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//                } else {
//                    return
//                }
//            case 3:
//                if (Options.getSegmentNotification(segment: 3)) {
//                    self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//                } else {
//                    return
//                }
//            default:
//                if (Options.getSegmentNotification(segment: 0)) {
//                    self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString, firstDate: firstDate)
//                } else {
//                    return
//                }
//            }
//        }
//    }
//
//    func createNotification(title: String, notes: String?, segment: Int, uuidString: String, firstDate: Date) {
//        // print("createNotification running")
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.sound = UNNotificationSound.default
//        content.threadIdentifier = String(AppDelegate().getItemSegment(id: uuidString))
//
//        content.badge = NSNumber(integerLiteral: AppDelegate().setBadgeNumber())
//
//        if let notesText = notes {
//            content.body = notesText
//        }
//
//        // Assign the category (and the associated actions).
//        switch segment {
//        case 1:
//            content.categoryIdentifier = "afternoon"
//        case 2:
//            content.categoryIdentifier = "evening"
//        case 3:
//            content.categoryIdentifier = "night"
//        default:
//            content.categoryIdentifier = "morning"
//        }
//
//        var dateComponents = DateComponents()
//        dateComponents.calendar = Calendar.autoupdatingCurrent
//        // Keep notifications from occurring too early for tasks created for tomorrow
//        dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: firstDate)
//        dateComponents.timeZone = TimeZone.autoupdatingCurrent
//        dateComponents.hour = getOptionHour(segment: segment)
//        dateComponents.minute = getOptionMinute(segment: segment)
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//
//        // Create the request
//        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
//
//        // Schedule the request with the system
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.add(request) { error in
//            if error != nil {
//                // TODO: handle notification errors
//                // print(String(describing: error))
//            } else {
//                // print("Notification created successfully")
//            }
//        }
//    }
//
//    func removeNotification(uuidString: [String]) {
//        // print("Removing Notifications")
//        let center = UNUserNotificationCenter.current()
//        center.removePendingNotificationRequests(withIdentifiers: uuidString)
//    }

    // MARK: Theme

    public func setAppearance(segment: Int) {
        // print("Setting theme")
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

//    func getDarkModeStatus() -> Bool {
//        var darkMode = false
//        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
//                    darkMode = options.darkMode
//                }
//            }
//        }
//        return darkMode
//    }

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
