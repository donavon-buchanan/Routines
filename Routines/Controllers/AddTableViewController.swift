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

    @IBOutlet var priorityNumberLabel: UILabel!

    @IBOutlet var prioritySlider: UISlider!
    @IBAction func prioritySliderChanged(_ sender: UISlider) {
        priorityNumberLabel.text = String(Int(sender.value))
    }

    @IBAction func prioritySliderTouched(_: UISlider) {
        view.endEditing(true)
        if item != nil, taskTextField.hasText {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

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

    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        TaskTableViewController.setAppearance(forSegment: sender.selectedSegmentIndex)
    }

    var item: Items?

    var editingSegment: Int?

    fileprivate func setUpUI() {
        // If item is loaded, fill in values for editing
        if item != nil {
            TaskTableViewController.setAppearance(forSegment: item!.segment)

            taskTextField.text = item?.title
            segmentSelection.selectedSegmentIndex = item?.segment ?? 0
            notesTextView.text = item?.notes
            repeatDailySwitch.setOn(item!.repeats, animated: false)
            priorityNumberLabel.text = "\(item?.priority ?? 0)"
            prioritySlider.value = Float(item?.priority ?? 0)

            title = "Editing Task"
        } else {
            title = "Adding New Task"
        }

        repeatDailySwitch.layer.cornerRadius = 15
        repeatDailySwitch.layer.masksToBounds = true

        repeatDailyLabel.theme_textColor = GlobalPicker.cellTextColors

        priorityNumberLabel.theme_textColor = GlobalPicker.textColor
        prioritySlider.theme_thumbTintColor = GlobalPicker.textColor

        if !RoutinesPlus.getPurchasedStatus() {
            prioritySlider.isEnabled = false
        } else {
            prioritySlider.isEnabled = true
        }
    }

    @objc func dismissView() {
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set right bar item as "Save"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
        // Disable button until all values are filled
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))

        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        let cellAppearance = UITableViewCell.appearance()
        cellAppearance.theme_backgroundColor = GlobalPicker.backgroundColor

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }

        // load in segment from add segue
        if let currentSegmentSelection = editingSegment {
            segmentSelection.selectedSegmentIndex = currentSegmentSelection
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.

        taskTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        segmentSelection.addTarget(self, action: #selector(textFieldDidChange), for: .valueChanged)
        notesTextView.delegate = self
        taskTextField.delegate = self

        notesTextView.layer.cornerRadius = 6
        notesTextView.layer.masksToBounds = true
        notesTextView.layer.borderWidth = 0.1
        notesTextView.layer.borderColor = UIColor.darkGray.cgColor

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

    override func encodeRestorableState(with coder: NSCoder) {
        // 1
        if let item = item {
            coder.encode(item.uuidString, forKey: "itemId")
        }

        // 2
        super.encodeRestorableState(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        let itemId = coder.decodeObject(forKey: "itemId") as! String
        let realm = try! Realm()
        item = realm.object(ofType: Items.self, forPrimaryKey: itemId)
        setUpUI()
        super.decodeRestorableState(with: coder)
    }

    override func applicationFinishedRestoringState() {
        TaskTableViewController.setAppearance(forSegment: item?.segment ?? 0)
    }

    override func viewWillAppear(_: Bool) {
        DispatchQueue.main.async {
            autoreleasepool {
                self.setUpUI()
            }
        }
    }

    override func viewDidAppear(_: Bool) {
        // UI doesn't know to scroll up if this is called too soon
        DispatchQueue.main.async {
            autoreleasepool {
                do {
                    self.taskTextField.becomeFirstResponder()
                }
            }
        }
    }

    @objc func setNotesEditable(_: UITapGestureRecognizer) {
        notesTextView.dataDetectorTypes = []
        notesTextView.isEditable = true
        notesTextView.becomeFirstResponder()
    }

    @objc func viewTapped() {
        view.endEditing(true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = false
        textView.dataDetectorTypes = .all
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
            repeatDailySwitch.setOn(!repeatDailySwitch.isOn, animated: true)
            if item != nil, taskTextField.hasText {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
        if indexPath.section == 2 {
            if !prioritySlider.isEnabled {
                segueToRoutinesPlusViewController()
            }
        }
    }

    @objc func textFieldDidChange() {
        if taskTextField.text!.count > 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
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
            updatedItem.updateItem(title: taskTextField.text!, segment: segmentSelection.selectedSegmentIndex, repeats: repeatDailySwitch.isOn, notes: notesTextView.text, priority: Int(prioritySlider.value))
        } else {
            let newItem = Items()
            newItem.title = taskTextField.text!
            newItem.segment = segmentSelection.selectedSegmentIndex
            newItem.originalSegment = segmentSelection.selectedSegmentIndex
            newItem.repeats = repeatDailySwitch.isOn
            newItem.notes = notesTextView.text
            newItem.priority = Int(prioritySlider.value)
            newItem.addNewItem(newItem)
        }
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }

    // MARK: Theme

    //    public func setAppearance(segment: Int) {
    //        // print("Setting theme")
    //        if Options.getDarkModeStatus() {
    //            switch segment {
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
    //            switch segment {
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
