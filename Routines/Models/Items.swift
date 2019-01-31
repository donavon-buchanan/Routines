//
//  Items.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift

// TODO: Figure out inits with Realm

@objcMembers class Items: Object {
    dynamic var title: String?
    dynamic var dateModified: Date?
    dynamic var segment: Int = 0
    dynamic var snoozeUntil: Date?
    dynamic var repeats: Bool = false
    dynamic var disableAutoSnooze: Bool = false
    dynamic var notes: String?

    // Date Components
    dynamic var year: Int?
    dynamic var month: Int?
    dynamic var day: Int?
    dynamic var hour: Int?
    dynamic var minute: Int?
    dynamic var weekday: Int?
    dynamic var weekdayOrdinal: Int?
    dynamic var quarter: Int?
    dynamic var weekOfMonth: Int?
    dynamic var weekOfYear: Int?

    // Repeats
    enum repeatStyle: String {
        case daily
        case weekly
        case monthly
        case yearly
        case none
    }

    dynamic var repeatStyle = "none"

    // Notification identifier
    dynamic var uuidString: String = UUID().uuidString
    override static func primaryKey() -> String? {
        return "uuidString"
    }

//    dynamic var afternoonUUID: String = UUID().uuidString
//    dynamic var eveningUUID: String = UUID().uuidString
//    dynamic var nightUUID: String = UUID().uuidString

    func setRepeat(time: DateComponents) {
        year = time.year
        month = time.month
        day = time.day
        hour = time.hour
        minute = time.minute
        weekday = time.weekday
        weekdayOrdinal = time.weekdayOrdinal
        quarter = time.quarter
        weekOfMonth = time.weekOfMonth
        weekOfYear = time.weekOfYear

        repeats = true
//        if repeats {
//            self.disableAutoSnooze = true
//        } else {
//            self.disableAutoSnooze = false
//        }
        // TODO: Just build a check in the view and the auto snooze func to check if repeat is enabled. Ignore if so. But don't actually change the value here.
        print("Repeat has been set.")
    }

    func repeatDaily(sunday: Bool, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, time: DateComponents) {
        var newTime = time

        if sunday {
            newTime.weekday = 1
        }
        if monday {
            newTime.weekday = 2
        }
        if tuesday {
            newTime.weekday = 3
        }
        if wednesday {
            newTime.weekday = 4
        }
        if thursday {
            newTime.weekday = 5
        }
        if friday {
            newTime.weekday = 6
        }
        if saturday {
            newTime.weekday = 7
        }
    }
}
