//
//  TableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: SwipeTableViewController {
    
    @IBAction func unwindToTableViewController(segue:UIStoryboardSegue){}
    
    // Get the default Realm
    let realm = try! Realm()

    //var segments: Results<Segments>?
    var items: Results<Items>?
    
    let dayString = "All Day"
    let morningString = "Morning"
    let afternoonString = "Afternoon"
    let eveningString = "Evening"
    let nightString = "Night"
    
    let segmentStringArray: [String] = ["Morning", "Afternoon", "Evening", "Night", "All Day"]

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
        // return the number of sections
//        var activeSegments = 0
//        for segment in 0...4 {
//            if countForSegment(section: segment) > 0 {
//                activeSegments += 1
//            }
//        }
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows, always at least 1 for default text
//        if countForSegment(section: section) > 0 {
//            return countForSegment(section: section)
//        } else {
//            return 1
//        }
        return countForSegment(section: section)
    }
    
    //Order of segments
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return segmentStringArray[section]
    }
    
    //@available(iOS 11.0, *)
    func visibleRect(for tableView: UITableView) -> CGRect? {
        if #available(iOS 11.0, *) {
            return tableView.safeAreaLayoutGuide.layoutFrame
        } else {
            // Fallback on earlier versions
            let topInset = navigationController?.navigationBar.frame.height ?? 0
            let bottomInset = navigationController?.toolbar?.frame.height ?? 0
            let bounds = tableView.bounds
            
            return CGRect(x: bounds.origin.x, y: bounds.origin.y + topInset, width: bounds.width, height: bounds.height - bottomInset)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let section = indexPath.section
        let item = performSearch(segment: section)[indexPath.row]
        if item.segment == indexPath.section {
            cell.textLabel?.text = item.title
        }
        //default text if no items in segment
//        if countForSegment(section: section) > 0 {
//            let item = performSearch(segment: section)[indexPath.row]
//            if item.segment == indexPath.section {
//                cell.textLabel?.text = item.title
//            }
//        } else {
//            cell.textLabel?.text = "Your \(segmentStringArray[indexPath.section].lowercased()) is clear!"
//        }
        
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
        
        //Set right bar item as "Save"
        destinationVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destinationVC, action: #selector(destinationVC.saveButtonPressed))
        //Disable button until all values are filled
        destinationVC.navigationItem.rightBarButtonItem?.isEnabled = false
//        if segue.identifier == "addSegue" {
//            let destination = segue.destination as! AddTableViewController
//            //Set right bar item as "Save"
//            destination.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destination, action: #selector(destination.saveButtonPressed))
//            //Disable button until all values are filled
//            destination.navigationItem.rightBarButtonItem?.isEnabled = false
//        }
//
//        if segue.identifier == "editSegue" {
//            let destination = segue.destination as! AddTableViewController
//            //Set right bar item as "Save"
//            destination.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destination, action: #selector(destination.saveButtonPressed))
//            //Disable button until a value is changed
//            destination.navigationItem.rightBarButtonItem?.isEnabled = false
//            //pass in current item
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let section = tableView.indexPathForSelectedRow?.section
//                destination.item = performSearch(segment: section!)[indexPath.row]
//            }
//        }
    }
    

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let item = items?[indexPath.row] {
//            do {
//                try realm.write {
//                    item.completed = !item.completed
//                }
//            } catch {
//                print("Error saving completed status: \(error)")
//            }
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//        tableView.reloadData()
//    }
    
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
    
    //Override empty delete func from super
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        if let item = self.items?[indexPath.row] {
            print("Deleting item with title: \(String(describing: item.title))")
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting item: \(error)")
            }
        }
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
