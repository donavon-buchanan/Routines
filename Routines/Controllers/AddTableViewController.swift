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
    
//    @IBAction func cancelButtonPressed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
    
    var item : Items?
    
    var itemTitle : String?
    
    // Get the default Realm
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If item is loaded, fill in values for editing
        if item != nil {
            taskTextField.text = item?.title
            segmentSelection.selectedSegmentIndex = (item?.segment)!
        }
        
        //print("Segment selection is: \(segmentSelection.selectedSegmentIndex)")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        taskTextField.addTarget(self, action: #selector(AddTableViewController.textFieldDidChange), for: .editingChanged)
        segmentSelection.addTarget(self, action: #selector(self.textFieldDidChange), for: .valueChanged)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination as! TableViewController
        destinationVC.tableView.reloadData()
    }
    
    @objc func textFieldDidChange() {
        if taskTextField.text!.count > 0 {
           itemTitle = taskTextField.text!
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            itemTitle = nil
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
    }
    
    @objc func saveButtonPressed() {
        addNewItem()
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }
 
    
    func addNewItem() {
        //if it's a new item, add it as new to the realm
        //otherwise, update the existing item
        if item == nil {
            let newItem = Items()
            newItem.title = itemTitle!
            newItem.dateModified = Date()
            newItem.segment = segmentSelection.selectedSegmentIndex
            
            //save to realm
            saveItem(item: newItem)
        } else {
            updateItem()
        }
    }
    
    func saveItem(item: Items) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
    func updateItem() {
        do {
            try realm.write {
                item!.title = itemTitle!
                item!.dateModified = Date()
                item!.segment = segmentSelection.selectedSegmentIndex
            }
        } catch {
            print("Error updating item: \(error)")
        }
    }

}
