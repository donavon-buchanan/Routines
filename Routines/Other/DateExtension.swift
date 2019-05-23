//
//  Date.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/11/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation

extension Date {
    var startOfNextDay: Date {
        return Calendar.autoupdatingCurrent.nextDate(after: self, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }

    var endOfDay: Date {
        return Calendar.autoupdatingCurrent.nextDate(after: self, matching: DateComponents(hour: 23, minute: 59), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }

    var nextDay: Date {
        return addingTimeInterval(86400)
    }

    var secondsUntilTheNextDay: TimeInterval {
        return startOfNextDay.timeIntervalSince(self)
    }
}
