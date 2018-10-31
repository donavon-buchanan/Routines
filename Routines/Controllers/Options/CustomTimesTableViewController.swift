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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.tableFooterView = UIView()
        
        //Set default minimum times
        let datePickerArray: [UIDatePicker] = [morningDatePicker, afternoonDatePicker, eveningDatePicker, nightDatePicker]
        setDefaultMinTimes(datePickerArray: datePickerArray, gapInSeconds: 60)
        
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
            numberOfRows = 0
        }
        
        return numberOfRows
    }
    
    //Set default min times
    func setDefaultMinTimes(datePickerArray: [UIDatePicker], gapInSeconds: Double) {
        let pickerCount = datePickerArray.count
        for picker in 1..<pickerCount {
            datePickerArray[picker].minimumDate = datePickerArray[picker-1].date.addingTimeInterval(gapInSeconds * 60)
        }
    }

}
