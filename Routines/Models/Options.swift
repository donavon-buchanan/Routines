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
    
    dynamic var morningNotificationsOn: Bool = false
    dynamic var afternoonNotificationsOn: Bool = false
    dynamic var eveningNotificationsOn: Bool = false
    dynamic var nightNotificationsOn: Bool = false
    
    dynamic var firstItemAdded: Bool = false
    
    dynamic var optionsKey = UUID().uuidString
    override static func primaryKey() -> String? {
        return "optionsKey"
    }
    
}
