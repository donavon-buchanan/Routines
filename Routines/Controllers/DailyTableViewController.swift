//
//  DailyTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 1/5/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

class DailyTableViewController: UITableViewController {
    let cellAppearance = UITableViewCell.appearance()
    let labelAppearance = UILabel.appearance()
    let tableAppearance = UITableView.appearance()

    let todayPath = IndexPath(row: 0, section: 0)
    let weekdaysPath = IndexPath(row: 1, section: 0)
    let weekendsPath = IndexPath(row: 2, section: 0)
    let everyDayPath = IndexPath(row: 3, section: 0)

    let sundayPath = IndexPath(row: 0, section: 1)
    let mondayPath = IndexPath(row: 1, section: 1)
    let tuesdayPath = IndexPath(row: 2, section: 1)
    let wednesdayPath = IndexPath(row: 3, section: 1)
    let thursdayPath = IndexPath(row: 4, section: 1)
    let fridayPath = IndexPath(row: 5, section: 1)
    let saturdayPath = IndexPath(row: 6, section: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

//        tableAppearance.theme_backgroundColor = GlobalPicker.backgroundColor
//        cellAppearance.theme_backgroundColor = GlobalPicker.cellBackground
//        labelAppearance.theme_textColor = GlobalPicker.cellTextColors
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.allowsMultipleSelection = false
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)

            switch indexPath.row {
            case 0:
                tableView.allowsMultipleSelection = true
                tableView.selectRow(at: selectToday(), animated: false, scrollPosition: UITableView.ScrollPosition.none)
            case 1:
                tableView.allowsMultipleSelection = true
                tableView.selectRow(at: mondayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: tuesdayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: wednesdayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: thursdayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: fridayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            case 2:
                tableView.allowsMultipleSelection = true
                tableView.selectRow(at: saturdayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: sundayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            case 3:
                tableView.allowsMultipleSelection = true
                tableView.selectRow(at: mondayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: tuesdayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: wednesdayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: thursdayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: fridayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: saturdayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                tableView.selectRow(at: sundayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            default:
                break
            }

        } else {
            selectionChanged()
        }
    }

    override func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectionChanged()
        }
    }

    func selectionChanged() {
        let weekdaysPathArray = [mondayPath, tuesdayPath, wednesdayPath, thursdayPath, fridayPath]
        let weekendsPathArray = [saturdayPath, sundayPath]
        let everydayPathArray = [sundayPath, mondayPath, tuesdayPath, wednesdayPath, thursdayPath, fridayPath, saturdayPath]

        // First deselect all the rows in the quick selection section
        tableView.deselectRow(at: todayPath, animated: false)
        tableView.deselectRow(at: weekdaysPath, animated: false)
        tableView.deselectRow(at: weekendsPath, animated: false)
        tableView.deselectRow(at: everyDayPath, animated: false)
        tableView.allowsMultipleSelection = true

        // Then make the quick selections match when appropriate
        if let selections = tableView.indexPathsForSelectedRows {
            // Have to run the check against sorted arrays
            switch selections.sorted() {
            case [selectToday()]:
                tableView.deselectRow(at: weekdaysPath, animated: false)
                tableView.deselectRow(at: weekendsPath, animated: false)
                tableView.deselectRow(at: everyDayPath, animated: false)
                tableView.selectRow(at: todayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            case weekdaysPathArray.sorted():
                tableView.deselectRow(at: weekendsPath, animated: false)
                tableView.deselectRow(at: everyDayPath, animated: false)
                tableView.deselectRow(at: todayPath, animated: false)
                tableView.selectRow(at: weekdaysPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            case weekendsPathArray.sorted():
                tableView.deselectRow(at: weekdaysPath, animated: false)
                tableView.deselectRow(at: everyDayPath, animated: false)
                tableView.deselectRow(at: todayPath, animated: false)
                tableView.selectRow(at: weekendsPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            case everydayPathArray.sorted():
                tableView.deselectRow(at: weekdaysPath, animated: false)
                tableView.deselectRow(at: weekendsPath, animated: false)
                tableView.deselectRow(at: todayPath, animated: false)
                tableView.selectRow(at: everyDayPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            default:
                break
            }
        }
    }

    // MARK: - Selections

    func selectToday() -> IndexPath {
        var dayIndex = 0
        var indexPath = IndexPath(row: 0, section: 1)

        let today = Calendar.autoupdatingCurrent.dateComponents([.weekday], from: Date())
        dayIndex = today.weekday!

        indexPath.row = dayIndex - 1

        return indexPath
    }
}
