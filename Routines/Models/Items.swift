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
    
    func setRepeat(repeats: Bool, year: Int?, month: Int?, day: Int?, hour: Int?, minute: Int?, weekday: Int?, weekdayOrdinal: Int?, quarter: Int?, weekOfMonth: Int?, weekOfYear: Int?) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.weekday = weekday
        self.weekdayOrdinal = weekdayOrdinal
        self.quarter = quarter
        self.weekOfMonth = weekOfMonth
        self.weekOfYear = weekOfYear
        
        self.repeats = repeats
//        if repeats {
//            self.disableAutoSnooze = true
//        } else {
//            self.disableAutoSnooze = false
//        }
        //TODO: Just build a check in the view and the auto snooze func to check if repeat is enabled. Ignore if so. But don't actually change the value here.
        print("Repeat has been set.")
    }
    
}
