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
    var secondsUntilTheNextDay: TimeInterval {
        return startOfNextDay.timeIntervalSince(self)
    }
}
