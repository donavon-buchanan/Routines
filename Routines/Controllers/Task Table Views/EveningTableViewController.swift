//
//  EveningTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/1/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

class EveningTableViewController: TaskTableViewController {

    let segment = 2
    
    override func returnSegment() -> Int {
        return segment
    }
}
