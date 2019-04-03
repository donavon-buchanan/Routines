//
//  Items.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import IceCream
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

    // For syncing
    dynamic var isDeleted: Bool = false

    // Repeats
    dynamic var repeatStyle = "none"
    var daysToRepeat = List<String>()

    // Notification identifier
    dynamic var uuidString: String = UUID().uuidString
    override static func primaryKey() -> String? {
        return "uuidString"
    }

    func setRepeat(style: String) {
        repeats = true
        repeatStyle = style
        // TODO: Just build a check in the view and the auto snooze func to check if repeat is enabled. Ignore if so. But don't actually change the value here.
        print("Repeat has been set.")
    }

    func repeatDaily(sunday: Bool, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool) {
        let days = List<String>()
        if sunday {
            days.append("sunday")
        }
        if monday {
            days.append("monday")
        }
        if tuesday {
            days.append("tuesday")
        }
        if wednesday {
            days.append("wednesday")
        }
        if thursday {
            days.append("thursday")
        }
        if friday {
            days.append("friday")
        }
        if saturday {
            days.append("saturday")
        }
        daysToRepeat = days
        setRepeat(style: "daily")
    }
}

extension Items: CKRecordConvertible {
    // Yep, leave it blank!
}

extension Items: CKRecordRecoverable {
    // Leave it blank, too.
}
