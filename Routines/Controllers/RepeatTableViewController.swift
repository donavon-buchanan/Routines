//
//  RepeatTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/24/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import SwiftTheme
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

    override func viewWillAppear(_: Bool) {
        setUpUI()
    }

    func setUpUI() {
        let dummyLabel = UILabel()
        if Options.getDarkModeStatus() {
            dummyLabel.theme_textColor = GlobalPicker.barTextColor
        } else {
            dummyLabel.theme_textColor = GlobalPicker.cellIndicatorTint
        }

        tableView.theme_backgroundColor = GlobalPicker.backgroundColor

//        if self.repeats == false {
//            disableSelectionCell.isHighlighted = true
//        }

        cells.forEach { cell in
            cell.theme_backgroundColor = GlobalPicker.backgroundColor
            cell.textLabel?.theme_textColor = GlobalPicker.cellTextColors
            cell.detailTextLabel?.theme_textColor = GlobalPicker.cellTextColors

//            if cell.isHighlighted {
//                cell.layer.shadowColor = dummyLabel.textColor.cgColor
//                cell.layer.shadowOffset = .zero
//                cell.layer.shadowRadius = 10
//                cell.layer.shadowOpacity = 1
//                cell.layer.masksToBounds = false
//            }
        }
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

     // Configure the cell...

     return cell
     }
     */

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
