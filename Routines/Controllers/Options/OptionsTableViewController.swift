//
//  OptionsTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

class OptionsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 4
        case 2:
            numberOfRows = 1
        default:
            numberOfRows = 0
        }
        
        return numberOfRows
    }

    //TODO: Add Notifications toggles
    //TODO: Add About section with version + build number

}
