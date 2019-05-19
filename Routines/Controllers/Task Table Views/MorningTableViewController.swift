//
//  MorningTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/19/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

class MorningTableViewController: TaskTableViewController {
    override var segment: Int {
        return 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func applicationFinishedRestoringState() {
        // I'm not sure why yet, but state restoration iterates through all the task views and calling this method is the only thing that prevents an ugly white flash for now. I hate everything about how this is set up.
        setAppearance(forSegment: segment)
        printDebug("Restoring state for task table view: \(segment)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setAppearance(forSegment: segment)
    }
}
