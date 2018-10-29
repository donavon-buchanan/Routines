//
//  Options.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/29/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Options: Object {
    dynamic var segment0StartTime: Date?
    dynamic var segment1StartTime: Date?
    dynamic var segment2StartTime: Date?
    dynamic var segment3StartTime: Date?
    
    dynamic var firstItemAdded: Bool = false
    
    dynamic var optionsKey = UUID().uuidString
    override static func primaryKey() -> String? {
        return "optionsKey"
    }
    
}
