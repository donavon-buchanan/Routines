//
//  CustomTimesTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

//TODO: You need to fetch uuidStrings on all current items and modify their associated notifications to match any updated times. Run those updates in async. It could be many.

import UIKit
import RealmSwift

class CustomTimesTableViewController: UITableViewController {
    
    @IBOutlet weak var morningDatePicker: UIDatePicker!
    @IBOutlet weak var afternoonDatePicker: UIDatePicker!
    @IBOutlet weak var eveningDatePicker: UIDatePicker!
    @IBOutlet weak var nightDatePicker: UIDatePicker!
    
    @IBAction func morningTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes(segment: 0, time: sender.date)
        print("Picker sent: \(String(describing: sender.date))")
    }
    @IBAction func afternoonTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes(segment: 1, time: sender.date)
        print("Picker sent: \(String(describing: sender.date))")
    }
    @IBAction func eveningTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes(segment: 2, time: sender.date)
        print("Picker sent: \(String(describing: sender.date))")
    }
    @IBAction func nightTimeSet(_ sender: UIDatePicker) {
        setMinMaxTimes()
        updateSavedTimes(segment: 3, time: sender.date)
        print("Picker sent: \(String(describing: sender.date))")
    }
    
    let realmDispatchQueueLabel: String = "background"

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.tableFooterView = UIView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadOptions()
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
    
//    //Options Properties
//    let optionsRealm = try! Realm()
//    var optionsObject: Options?
//    //var firstItemAdded: Bool?
    let optionsKey = "optionsKey"
    
//    //Load Options
//    func loadOptions() {
//        optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey)
//    }
    
    func updateSavedTimes(segment: Int, time: Date) {
        print("updateSavedTimes received: \(String(describing: time))")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                do {
                    try realm.write {
                        switch segment {
                        case 1:
                            options?.self.afternoonStartTime = time
                        case 2:
                            options?.self.eveningStartTime = time
                        case 3:
                            options?.self.nightStartTime = time
                        default:
                            options?.self.morningStartTime = time
                        }
                        print("updateSavedTime: Options \(String(describing: options))")
                    }
                } catch {
                    print("updateSavedTimes failed")
                }
            }
        }
    }
    
    func setUpUI() {
        if let morningTime = getTimesFromOptions(segment: 0) {
            self.morningDatePicker.setDate(morningTime, animated: false)
        }
        if let afternoonTime = getTimesFromOptions(segment: 1) {
            self.afternoonDatePicker.setDate(afternoonTime, animated: false)
        }
        if let eveningTime = getTimesFromOptions(segment: 2) {
            self.eveningDatePicker.setDate(eveningTime, animated: false)
        }
        if let nightTime = getTimesFromOptions(segment: 3) {
            self.nightDatePicker.setDate(nightTime, animated: false)
        }
    }
    
    func getTimesFromOptions(segment: Int) -> Date? {
        var date: Date?
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    date = options?.afternoonStartTime
                case 2:
                    date = options?.eveningStartTime
                case 3:
                    date = options?.nightStartTime
                default:
                    date = options?.morningStartTime
                }
            }
        }
        return date
    }

}
