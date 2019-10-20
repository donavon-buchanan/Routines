//
//  RepeatTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/24/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

// import SwiftTheme
import UIKit

class RepeatTableViewController: UITableViewController {
    // Date Components
    var year: Int?
    var month: Int?
    var day: Int?
    var hour: Int?
    var minute: Int?
    var weekday: Int?
    var weekdayOrdinal: Int?
    var quarter: Int?
    var weekOfMonth: Int?
    var weekOfYear: Int?

    var repeats: Bool = false

    @IBOutlet var cells: [UITableViewCell]!
    @IBOutlet var disableSelectionCell: UITableViewCell!
    @IBOutlet var dailySelectionCell: UITableViewCell!
    @IBOutlet var weeklySelectionCell: UITableViewCell!
    @IBOutlet var monthlySelectionCell: UITableViewCell!
    @IBOutlet var yearlySelectionCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

//    override func viewWillAppear(_: Bool) {
//        setUpUI()
//    }
//
//    func setUpUI() {
//        let dummyLabel = UILabel()
//        if Options.getDarkModeStatus() {
//            dummyLabel.theme_textColor = GlobalPicker.barTextColor
//        } else {
//            dummyLabel.theme_textColor = GlobalPicker.cellIndicatorTint
//        }
//
//        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
//
//        cells.forEach { cell in
//            cell.theme_backgroundColor = GlobalPicker.backgroundColor
//            cell.textLabel?.theme_textColor = GlobalPicker.cellTextColors
//            cell.detailTextLabel?.theme_textColor = GlobalPicker.cellTextColors
//        }
//    }
}
