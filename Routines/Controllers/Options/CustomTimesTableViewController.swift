//
//  CustomTimesTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

class CustomTimesTableViewController: UITableViewController {
    
    @IBOutlet weak var morningDatePicker: UIDatePicker!
    @IBOutlet weak var afternoonDatePicker: UIDatePicker!
    @IBOutlet weak var eveningDatePicker: UIDatePicker!
    @IBOutlet weak var nightDatePicker: UIDatePicker!
    
    @IBAction func morningTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes()
    }
    @IBAction func afternoonTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes()
    }
    @IBAction func eveningTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes()
    }
    @IBAction func nightTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.tableFooterView = UIView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOptions()
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMinMaxTimes()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 1
        case 2:
            numberOfRows = 1
        case 3:
            numberOfRows = 1
        default:
            numberOfRows = 1
        }
        
        return numberOfRows
    }
    
    //Set default min times
    func setDefaultMinTimes() {
        let datePickerArray: [UIDatePicker] = [morningDatePicker, afternoonDatePicker, eveningDatePicker, nightDatePicker]
        let pickerCount = datePickerArray.count
        for picker in 1..<pickerCount {
            datePickerArray[picker].minimumDate = datePickerArray[picker-1].date.addingTimeInterval(3600)
        }
    }
    
    func setDefaultMaxTimes() {
        let maxTimeString = "11:00 PM"
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let maxTime = dateFormatter.date(from: maxTimeString)
        nightDatePicker.maximumDate = maxTime
        
        let datePickerArray: [UIDatePicker] = [nightDatePicker, eveningDatePicker, afternoonDatePicker, morningDatePicker]
        let pickerCount = datePickerArray.count
        for picker in 1..<pickerCount {
            datePickerArray[picker].maximumDate = datePickerArray[picker-1].date.addingTimeInterval(0)
        }
    }
    
    func setMinMaxTimes() {
        setDefaultMinTimes()
        setDefaultMaxTimes()
    }
    
    //MARK: - Options Realm
    
    //Options Properties
    let optionsRealm = try! Realm()
    var optionsObject: Options?
    //var firstItemAdded: Bool?
    let optionsKey = "optionsKey"
    
    //Load Options
    func loadOptions() {
        optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey)
    }
    
    func updateSavedTimes() {
        do {
            try self.optionsRealm.write {
                optionsObject?.morningStartTime = morningDatePicker.date
                optionsObject?.afternoonStartTime = afternoonDatePicker.date
                optionsObject?.eveningStartTime = eveningDatePicker.date
                optionsObject?.nightStartTime = nightDatePicker.date
                print("updateSavedTime: \(String(describing: optionsObject))")
            }
        } catch {
            print("failed to update notification saved times")
        }
    }
    
    func setUpUI() {
        if let morningTime = optionsObject?.morningStartTime {
            morningDatePicker.setDate(morningTime, animated: false)
        }
        if let afternoonTime = optionsObject?.afternoonStartTime {
            afternoonDatePicker.setDate(afternoonTime, animated: false)
        }
        if let eveningTime = optionsObject?.eveningStartTime {
            eveningDatePicker.setDate(eveningTime, animated: false)
        }
        if let nightTime = optionsObject?.nightStartTime {
            nightDatePicker.setDate(nightTime, animated: false)
        }
    }

}
