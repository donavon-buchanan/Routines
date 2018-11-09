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
    
    dynamic var morningStartTime: DateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, era: nil, year: nil, month: nil, day: nil, hour: 7, minute: 0, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    dynamic var afternoonStartTime: DateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, era: nil, year: nil, month: nil, day: nil, hour: 12, minute: 0, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    dynamic var eveningStartTime: DateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, era: nil, year: nil, month: nil, day: nil, hour: 17, minute: 0, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    dynamic var nightStartTime: DateComponents = DateComponents(calendar: Calendar.autoupdatingCurrent, timeZone: TimeZone.autoupdatingCurrent, era: nil, year: nil, month: nil, day: nil, hour: 21, minute: 0, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
    
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
