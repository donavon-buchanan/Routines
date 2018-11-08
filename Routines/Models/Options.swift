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
    
    dynamic var morningStartTime: Date?
    dynamic var afternoonStartTime: Date?
    dynamic var eveningStartTime: Date?
    dynamic var nightStartTime: Date?
    
    dynamic var morningNotificationsOn: Bool = true
    dynamic var afternoonNotificationsOn: Bool = true
    dynamic var eveningNotificationsOn: Bool = true
    dynamic var nightNotificationsOn: Bool = true
    
    dynamic var firstItemAdded: Bool = false
    
    dynamic var smartSnooze: Bool = false
    
    dynamic var optionsKey = UUID().uuidString
    override static func primaryKey() -> String? {
        return "optionsKey"
    }
    
}
