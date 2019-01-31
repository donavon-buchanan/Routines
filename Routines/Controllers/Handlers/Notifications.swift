//
//  Notifications.swift
//  Routines
//
//  Created by Donavon Buchanan on 1/30/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications

class Notifications {
    public func removeNotifications(forSegment segment: Int) {
        let center = UNUserNotificationCenter.current()
        let realm = try! Realm()
        let items = realm.objects(Items.self).filter("segment = \(segment)")
        var idStrings: [String] = []
        items.forEach { item in
            idStrings.append(item.uuidString + "\(segment)")
        }
        center.removePendingNotificationRequests(withIdentifiers: idStrings)
    }
}
