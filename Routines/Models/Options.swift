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

    dynamic var morningHour: Int = 7
    dynamic var morningMinute: Int = 0

    dynamic var afternoonHour: Int = 12
    dynamic var afternoonMinute: Int = 0

    dynamic var eveningHour: Int = 17
    dynamic var eveningMinute: Int = 0

    dynamic var nightHour: Int = 21
    dynamic var nightMinute: Int = 0

    dynamic var morningNotificationsOn: Bool = true
    dynamic var afternoonNotificationsOn: Bool = true
    dynamic var eveningNotificationsOn: Bool = true
    dynamic var nightNotificationsOn: Bool = true

    dynamic var badge: Bool = true

    dynamic var firstItemAdded: Bool = false

    dynamic var smartSnooze: Bool = false

    dynamic var darkMode: Bool = true
    dynamic var themeIndex: Int = 0

    dynamic var selectedIndex: Int = 0

    dynamic var optionsKey = UUID().uuidString
    override static func primaryKey() -> String? {
        return "optionsKey"
    }
}
