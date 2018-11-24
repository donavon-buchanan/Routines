//
//  Items.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift


//TODO: Figure out inits with Realm

@objcMembers class Items: Object {
    dynamic var title: String?
    dynamic var dateModified: Date?
    dynamic var segment: Int = 0
    dynamic var snoozeUntil: Date?
    dynamic var repeats: Bool = false
    dynamic var disableAutoSnooze: Bool = false
    dynamic var notes: String?
    
    //Date Components
    dynamic var year : Int?
    dynamic var month: Int?
    dynamic var day: Int?
    dynamic var hour: Int?
    dynamic var minute: Int?
    dynamic var weekday: Int?
    dynamic var weekdayOrdinal: Int?
    dynamic var quarter: Int?
    dynamic var weekOfMonth: Int?
    dynamic var weekOfYear: Int?
    
    
    //Notification identifier
    dynamic var uuidString: String = UUID().uuidString
    override static func primaryKey() -> String? {
        return "uuidString"
    }
    
//    dynamic var afternoonUUID: String = UUID().uuidString
//    dynamic var eveningUUID: String = UUID().uuidString
//    dynamic var nightUUID: String = UUID().uuidString
    
}
