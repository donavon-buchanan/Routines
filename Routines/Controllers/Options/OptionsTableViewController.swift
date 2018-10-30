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
        
        //disableScrolling()
    }
    
    override func viewDidLayoutSubviews() {
        disableScrolling()
    }

    //TODO: Add Notifications toggles
    //TODO: Add About section with version + build number

}
