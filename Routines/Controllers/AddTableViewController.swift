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
    @IBOutlet weak var notesTextView: UITextView!
    
    
//    @IBAction func cancelButtonPressed(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
//    }
    
    var item : Items?
    
    //segment from add segue
    var editingSegment: Int?
    
    var itemTitle : String?
    
    // Get the default Realm
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        //Set height of notes view
//        self.notesTextView.translatesAutoresizingMaskIntoConstraints = false
//        self.notesTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        //If item is loaded, fill in values for editing
        if item != nil {
            taskTextField.text = item?.title
            segmentSelection.selectedSegmentIndex = item?.segment ?? 0
            notesTextView.text = item?.notes
        }

        //print("Segment selection is: \(segmentSelection.selectedSegmentIndex)")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //load in segment from add segue
        if let currentSegmentSelection = editingSegment {
            segmentSelection.selectedSegmentIndex = currentSegmentSelection
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        taskTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        segmentSelection.addTarget(self, action: #selector(self.textFieldDidChange), for: .valueChanged)
        
        //handle keyboard
//        self.taskTextField.delegate = self
//        self.notesTextView.delegate = self
        
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination as! TableViewController
        //destinationVC.tableView.reloadData()

        //Set the segment after adding or editing an item
        destinationVC.setSegment = segmentSelection.selectedSegmentIndex
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
    
    //dismiss keyboard
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//        textField.resignFirstResponder()
//
//        return true
//    }
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        textView.resignFirstResponder()
//        return true
//    }
    
//    @objc func notesTextViewDidChange(_ textView: UITextView) {
//
//    }
    
    @objc func saveButtonPressed() {
        addNewItem()
        print("Added or saved item")
        //performSegue(withIdentifier: "unwindToTableViewController", sender: self)
        print("Unwind segue")
        navigationController?.popViewController(animated: true)
    }
 
    
    func addNewItem() {
        //if it's a new item, add it as new to the realm
        //otherwise, update the existing item
        if item == nil {
            let newItem = Items()
            newItem.title = itemTitle!
            newItem.dateModified = Date()
            newItem.segment = segmentSelection.selectedSegmentIndex
            newItem.notes = notesTextView.text
            
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
                item!.notes = notesTextView.text
            }
        } catch {
            print("Error updating item: \(error)")
        }
    }

}
