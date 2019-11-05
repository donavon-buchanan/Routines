//
//  AddTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/23/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import UIKit
import UserNotifications

class AddTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {
    // MARK: - Properties

    func segmentColor(segment: Int) -> UIColor {
        switch segment {
        case 0:
            return UIColor(displayP3Red: 0.96, green: 0.46, blue: 0.27, alpha: 1.0)
        case 1:
            return UIColor(displayP3Red: 0.15, green: 0.73, blue: 0.93, alpha: 1.0)
        case 2:
            return UIColor(displayP3Red: 0.38, green: 0.64, blue: 0.53, alpha: 1.0)
        case 3:
            return UIColor(displayP3Red: 0.39, green: 0.36, blue: 0.91, alpha: 1.0)
        default:
            return UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }

//    @IBOutlet var priorityNumberLabel: UILabel!
//
//    @IBOutlet var prioritySlider: UISlider!
//    @IBAction func prioritySliderChanged(_ sender: UISlider) {
//        priorityNumberLabel.text = String(Int(sender.value))
//    }
//
//    @IBAction func prioritySliderTouched(_: UISlider) {
//        view.endEditing(true)
//        if task != nil, taskTextField.hasText {
//            navigationItem.rightBarButtonItem?.isEnabled = true
//        }
//    }

    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var segmentSelection: UISegmentedControl!

    @IBOutlet var notesTextView: UITextView!

    @IBOutlet var repeatDailySwitch: UISwitch!
    @IBAction func repeatDailySwitchToggled(_: UISwitch) {
        if task != nil, taskTextField.hasText {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(title: "Save Task", action: #selector(saveKeyCommand), input: "s", modifierFlags: .command),
            UIKeyCommand(title: "Exit", action: #selector(dismissView), input: UIKeyCommand.inputEscape),
            UIKeyCommand(title: "Toggle Repeat Daily", action: #selector(toggleRepeat), input: "r", modifierFlags: .command),
            UIKeyCommand(title: "Select Morning", action: #selector(setSegmentZero), input: "1", modifierFlags: .command),
            UIKeyCommand(title: "Select Afternoon", action: #selector(setSegmentOne), input: "2", modifierFlags: .command),
            UIKeyCommand(title: "Select Evening", action: #selector(setSegmentTwo), input: "3", modifierFlags: .command),
            UIKeyCommand(title: "Select Night", action: #selector(setSegmentThree), input: "4", modifierFlags: .command),
        ]
    }

    @objc func saveKeyCommand() {
        if navigationItem.rightBarButtonItem!.isEnabled {
            saveButtonPressed()
        }
    }

    @objc func toggleRepeat() {
        repeatDailySwitch.setOn(!repeatDailySwitch.isOn, animated: true)
    }

    @objc func setSegmentZero() {
        segmentSelection.selectedSegmentIndex = 0
//        TaskTableViewController.setAppearance(forSegment: 0)
        segmentSelection.selectedSegmentTintColor = UIColor(segment: segmentSelection.selectedSegmentIndex)
    }

    @objc func setSegmentOne() {
        segmentSelection.selectedSegmentIndex = 1
//        TaskTableViewController.setAppearance(forSegment: 1)
        segmentSelection.selectedSegmentTintColor = UIColor(segment: segmentSelection.selectedSegmentIndex)
    }

    @objc func setSegmentTwo() {
        segmentSelection.selectedSegmentIndex = 2
//        TaskTableViewController.setAppearance(forSegment: 2)
        segmentSelection.selectedSegmentTintColor = UIColor(segment: segmentSelection.selectedSegmentIndex)
    }

    @objc func setSegmentThree() {
        segmentSelection.selectedSegmentIndex = 3
//        TaskTableViewController.setAppearance(forSegment: 3)
        segmentSelection.selectedSegmentTintColor = UIColor(segment: segmentSelection.selectedSegmentIndex)
    }

    @IBOutlet var repeatDailyLabel: UILabel!

//    @IBAction func segmentSelected(sender: UISegmentedControl) {
//        sender.selectedSegmentTintColor = segmentColor(segment: sender.selectedSegmentIndex)
//    }

    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        sender.selectedSegmentTintColor = UIColor(segment: sender.selectedSegmentIndex)
    }

    var task: Task?
    var selectedIndex: Int?

    var editingSegment: Int?
    var shouldShowHiddenTasksMessage = false

    func loadTask() {
        // If task is loaded, fill in values for editing
        if task != nil {
//            TaskTableViewController.setAppearance(forSegment: task!.segment)

            taskTextField.text = task?.title
            segmentSelection.selectedSegmentIndex = task?.segment ?? 0
            notesTextView.text = task?.notes
            repeatDailySwitch.setOn(task!.repeats, animated: false)

            title = "Editing Task"
        } else {
            title = "Adding New Task"
        }
    }

    fileprivate func setUpUI() {
        if let selectedIndex = self.selectedIndex {
            print("Appearance condition 1")
            navigationController?.navigationBar.tintColor = UIColor(segment: selectedIndex)
            UISwitch.appearance().onTintColor = UIColor(segment: selectedIndex)
            segmentSelection.selectedSegmentTintColor = UIColor(segment: selectedIndex)
        } else if let currentTask = task {
            print("Appearance condition 2")
            print("Setting appearance for index of \(currentTask.segment)")
            // I'm not sure why, but the method below doesn't change the color in time
            // Needs to be done more directly here
            //            setAppearance(forSegment: currentTask.segment)
            navigationController?.navigationBar.tintColor = UIColor(segment: currentTask.segment)
            UISwitch.appearance().onTintColor = UIColor(segment: currentTask.segment)
            segmentSelection.selectedSegmentTintColor = UIColor(segment: currentTask.segment)
        } else {
            navigationController?.navigationBar.tintColor = UIColor(segment: Options.getNextSegmentFromTime())
            UISwitch.appearance().onTintColor = UIColor(segment: Options.getNextSegmentFromTime())
            segmentSelection.selectedSegmentIndex = Options.getNextSegmentFromTime()
            segmentSelection.selectedSegmentTintColor = UIColor(segment: Options.getNextSegmentFromTime())
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
//        if segue.identifier == "unwindToTableViewController" {
//            let destination = segue.destination as! TaskTableViewController
//            if shouldShowHiddenTasksMessage {
//                destination.shouldShowHiddenTasksMessage = shouldShowHiddenTasksMessage
//            }
//        }
//    }

    @objc func dismissView() {
//        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()

        // Set right bar task as "Save"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
        // Disable button until all values are filled
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))

//        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

//        let cellAppearance = UITableViewCell.appearance()
//        cellAppearance.theme_backgroundColor = GlobalPicker.backgroundColor

        // load in segment from add segue
        if let currentSegmentSelection = editingSegment {
            segmentSelection.selectedSegmentIndex = currentSegmentSelection
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.

        taskTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        segmentSelection.addTarget(self, action: #selector(textFieldDidChange), for: .valueChanged)
        notesTextView.delegate = self
        taskTextField.delegate = self
        taskTextField.backgroundColor = UIColor.tertiarySystemBackground

        notesTextView.layer.cornerRadius = 6
        notesTextView.layer.masksToBounds = true
        notesTextView.layer.borderWidth = 0.1
        notesTextView.backgroundColor = UIColor.tertiarySystemBackground

        // Add tap gesture for editing notes
        let textFieldTap = UITapGestureRecognizer(target: self, action: #selector(setNotesEditable))
        notesTextView.addGestureRecognizer(textFieldTap)

        // add a tap recognizer to stop editing when tapping outside the textView
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        viewTap.cancelsTouchesInView = false
        view.addGestureRecognizer(viewTap)

//        taskTextField.theme_keyboardAppearance = GlobalPicker.keyboardStyle
//        taskTextField.theme_textColor = GlobalPicker.cellTextColors
//        taskTextField.theme_backgroundColor = GlobalPicker.textInputBackground
//
//        notesTextView.theme_keyboardAppearance = GlobalPicker.keyboardStyle
//        notesTextView.theme_textColor = GlobalPicker.cellTextColors
//        notesTextView.theme_backgroundColor = GlobalPicker.textInputBackground
    }

    override func encodeRestorableState(with coder: NSCoder) {
        // 1
        if let task = task {
            coder.encode(task.uuidString, forKey: "taskId")
        }
        if taskTextField.hasText {
            coder.encode(taskTextField.text, forKey: "taskTextFieldText")
        }
        coder.encode(segmentSelection.selectedSegmentIndex, forKey: "selectedSegment")
        coder.encode(repeatDailySwitch.isOn, forKey: "repeatSwitch")
        if notesTextView.hasText {
            coder.encode(notesTextView.text, forKey: "notesText")
        }

        // 2
        super.encodeRestorableState(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        if let taskId = coder.decodeObject(forKey: "taskId") as? String {
            if let realm = try? Realm() {
                task = realm.object(ofType: Task.self, forPrimaryKey: taskId)
            }
        }
        
        taskTextField.text = coder.decodeObject(forKey: "taskTextFieldText") as? String
        let segment = coder.decodeInteger(forKey: "selectedSegment")
        self.editingSegment = segment
        self.selectedIndex = segment
        segmentSelection.selectedSegmentIndex = segment
        segmentSelection.selectedSegmentTintColor = segmentColor(segment: segment)
        
        repeatDailySwitch.isOn = coder.decodeBool(forKey: "repeatSwitch")
        repeatDailySwitch.setOn(coder.decodeBool(forKey: "repeatSwitch"), animated: false)
        
        notesTextView.text = coder.decodeObject(forKey: "notesText") as? String
        
        super.decodeRestorableState(with: coder)
    }

    override func applicationFinishedRestoringState() {
        setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.loadTask()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // UI doesn't know to scroll up if this is called too soon
        DispatchQueue.main.async {
            autoreleasepool {
                do {
//                    self.setUpUI()
                    #if !targetEnvironment(simulator)
                    self.taskTextField.becomeFirstResponder()
                    #endif
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
        textView.resignFirstResponder()
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This is a bad way to do this
        if indexPath.section == 2 {
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
            repeatDailySwitch.setOn(!repeatDailySwitch.isOn, animated: true)
            if task != nil, taskTextField.hasText {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }

    @objc func textFieldDidChange() {
        if taskTextField.hasText {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    func textViewDidChange(_: UITextView) {
        if task != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    @objc func saveButtonPressed() {
        if let updatedTask = task {
            updatedTask.updateTask(title: taskTextField.text!, segment: segmentSelection.selectedSegmentIndex, repeats: repeatDailySwitch.isOn, notes: notesTextView.text)
        } else {
//            let newTask = Task(title: taskTextField.text!, segment: segmentSelection.selectedSegmentIndex, priority: Int(prioritySlider.value), repeats: repeatDailySwitch.isOn, notes: notesTextView.text)
            let newTask = Task(title: taskTextField.text!, segment: segmentSelection.selectedSegmentIndex, repeats: repeatDailySwitch.isOn, notes: notesTextView.text)
            newTask.addNewTask()
            if newTask.completeUntil > Date().endOfDay {
                shouldShowHiddenTasksMessage = true
            }
        }
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }

    // MARK: - Banners

//    func showBanner(title: String?) {
//        SwiftMessages.pauseBetweenMessages = 0
//        SwiftMessages.hideAll()
//        SwiftMessages.show { () -> UIView in
//            let banner = MessageView.viewFromNib(layout: .statusLine)
//            banner.configureTheme(.success)
//            banner.configureContent(title: "", body: title ?? "Saved!")
//            return banner
//        }
//    }
}
