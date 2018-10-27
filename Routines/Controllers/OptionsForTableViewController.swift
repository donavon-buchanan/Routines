//
//  OptionsForTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 10/27/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

extension TableViewController {
    
    //Load Options
    func loadOptions() {
        optionsObject = optionsRealm.objects(Options.self)[0]
    }

}
