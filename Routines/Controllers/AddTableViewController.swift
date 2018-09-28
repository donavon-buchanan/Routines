//
//  AddTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/23/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

class AddTableViewController: UITableViewController {
    
    //MARK: - Properties
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var segmentSelection: UISegmentedControl!
    //save task
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("save button pressed")
        addNewItem()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var item = Items()
    
    // Get the default Realm
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item.title.count > 0 {
            taskTextField.text = item.title
            segmentSelection.selectedSegmentIndex = item.segment
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination as! TableViewController
        destinationVC.tableView.reloadData()
    }
 
    
    func addNewItem() {
        //if it's a new item, add it as new to the realm
        //otherwise, update the existing item
        if self.item.title.count == 0 {
            self.item.title = taskTextField.text!
            self.item.dateModified = Date()
            self.item.segment = segmentSelection.selectedSegmentIndex
            
            //save to realm
            saveItem(item: self.item)
        } else {
            updateItem()
        }
    }
    
    func saveItem(item: Items) {
        do {
            try realm.write {
                realm.add(self.item)
            }
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
    func updateItem() {
        do {
            try realm.write {
                item.title = taskTextField.text!
                item.dateModified = Date()
                item.segment = segmentSelection.selectedSegmentIndex
            }
        } catch {
            print("Error updating item: \(error)")
        }
    }

}
