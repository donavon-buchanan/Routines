//
//  InterfaceController.swift
//  Routines-WatchOS Extension
//
//  Created by Donavon Buchanan on 4/5/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation
import WatchKit

class InterfaceController: WKInterfaceController {
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
