//
//  NightTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/1/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

class NightTableViewController: TaskTableViewController {

    let segment = 3
    
    override func returnSegment() -> Int {
        return segment
    }
}
