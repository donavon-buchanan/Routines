//
//  AutomaticDarkModeTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/5/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

class AutomaticDarkModeTableViewController: UITableViewController {
    // MARK: - Properties

    @IBOutlet var automaticDarkModeLabel: UILabel!

    @IBOutlet var automaticDarkModeSwitch: UISwitch!
    @IBAction func automaticDarkModeSwitchAction(_ sender: UISwitch) {
        Options.setAutomaticDarkModeStatus(sender.isOn)

        perform(#selector(refreshUI), with: nil, afterDelay: 0.1)
    }

    @IBOutlet var startTimeDatePicker: UIDatePicker!
    @IBAction func startTimeDatePickerAction(_ sender: UIDatePicker) {
        let hour = Options.getHour(date: sender.date)
        let minute = Options.getMinute(date: sender.date)
        Options.setAutomaticDarkModeStartTime(hour: hour, minute: minute)
        Options.automaticDarkModeCheck()
        perform(#selector(refreshUI), with: nil, afterDelay: 0.1)
    }

    @IBOutlet var endTimeDatePicker: UIDatePicker!
    @IBAction func endTimeDatePickerAction(_ sender: UIDatePicker) {
        let hour = Options.getHour(date: sender.date)
        let minute = Options.getMinute(date: sender.date)
        Options.setAutomaticDarkModeEndTime(hour: hour, minute: minute)
        Options.automaticDarkModeCheck()
        perform(#selector(refreshUI), with: nil, afterDelay: 0.1)
    }

    func setUpUI() {
        // Set view theme
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

        // Get dates from Options for times
        if let startTime = Options.getAutomaticDarkModeStartTime() {
            startTimeDatePicker.setDate(startTime, animated: false)
        }
        if let endTime = Options.getAutomaticDarkModeEndTime() {
            endTimeDatePicker.setDate(endTime, animated: false)
        }

        // Get status of automaticDarkMode
        automaticDarkModeSwitch.setOn(Options.getAutomaticDarkModeStatus(), animated: false)

        // Set theme on date pickers
        // We can't assign a color directly to the date picker
        // But we can assign it to text that doesn't exist and then fetch the color from that
        let text = UILabel()
        text.theme_textColor = GlobalPicker.cellTextColors
        // Get color
        let textColor = text.textColor
        // Assign color
        startTimeDatePicker.setValue(textColor, forKeyPath: "textColor")
        endTimeDatePicker.setValue(textColor, forKeyPath: "textColor")

        // band-aid for graphical glitch when toggling dark mode
        automaticDarkModeSwitch.layer.cornerRadius = 15
        automaticDarkModeSwitch.layer.masksToBounds = true

        automaticDarkModeLabel.theme_textColor = GlobalPicker.cellTextColors
    }

    @objc func refreshUI() {
        DispatchQueue.main.async {
            // Set view theme
            self.tableView.theme_backgroundColor = GlobalPicker.backgroundColor

            // Set theme on date pickers
            // We can't assign a color directly to the date picker
            // But we can assign it to text that doesn't exist and then fetch the color from that
            let text = UILabel()
            text.theme_textColor = GlobalPicker.cellTextColors
            // Get color
            let textColor = text.textColor
            // Assign color
            self.startTimeDatePicker.setValue(textColor, forKeyPath: "textColor")
            self.endTimeDatePicker.setValue(textColor, forKeyPath: "textColor")

            self.automaticDarkModeLabel.theme_textColor = GlobalPicker.cellTextColors
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_: Bool) {
        setUpUI()
    }
}
