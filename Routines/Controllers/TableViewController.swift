//
//  TableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {
    
    // Get the default Realm
    let realm = try! Realm()

    //var segments: Results<Segments>?
    var items: Results<Items>?
    
    let dayString = "All Day"
    let morningString = "Morning"
    let afternoonString = "Afternoon"
    let eveningString = "Evening"
    let nightString = "Night"
    
    //let segmentStringArray: [String] = ["All Day", "Morning", "Afternoon", "Evening", "Night"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 50
        
        //TODO: - Scroll to currently relevant section
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countForSegment(section: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return morningString
        case 2:
            return afternoonString
        case 3:
            return eveningString
        case 4:
            return nightString
        default:
            return dayString
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let section = indexPath.section
        
        let item = performSearch(segment: section)[indexPath.row]
        if item.segment == indexPath.section {
            cell.textLabel?.text = item.title
        }
        
        return cell
    }
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destinationVC = segue.destination as! AddTableViewController
        // Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            let section = tableView.indexPathForSelectedRow?.section
            destinationVC.item = performSearch(segment: section!)[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //MARK: - Model Manipulation Methods
    //Load segments
//    func loadSegments() {
//        segments = realm.objects(Segments.self)
//        //self.tableView.reloadData()
//    }
    
    //load items
    func loadItems() {
        items = realm.objects(Items.self)
        //self.tableView.reloadData()
        print("loadItems run")
    }
    
    func loadData() {
        print("loadData run")
        //loadSegments()
        loadItems()
        self.tableView.reloadData()
    }
    
    //Ask for which section and count the items matching that section index to segment property
    func countForSegment(section: Int) -> Int {
        let count = performSearch(segment: section).count
        print("countForSegment run")
        print("count for segment \(section) is \(count)")
        return count
    }
    
    //Filter items to relevant segment and return those items
    func performSearch(segment: Int) -> Results<Items> {
        let filteredItems = items?.filter("segment = \(segment)").sorted(byKeyPath: "dateModified", ascending: true) ?? realm.objects(Items.self).filter("segment = \(segment)").sorted(byKeyPath: "dateModified", ascending: true)
        print("performSearch run")
        //self.tableView.reloadData()
        return filteredItems
    }
    
}
