//
//  Options.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/29/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

// import CloudKit
import Foundation
import IceCream
import RealmSwift

@objcMembers class Options: Object {
//    dynamic var morningStartTime: Date?
//    dynamic var afternoonStartTime: Date?
//    dynamic var eveningStartTime: Date?
//    dynamic var nightStartTime: Date?

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

    // TODO: This should be removed
    // dynamic var firstItemAdded: Bool = false

    // TODO: This should be renamed at some point in the future
    // dynamic var smartSnooze: Bool = false

    dynamic var darkMode: Bool = true
    dynamic var themeIndex: Int = 0

    dynamic var selectedIndex: Int = 0

    dynamic var optionsKey = UUID().uuidString
    override static func primaryKey() -> String {
        return "optionsKey"
    }

    static let realmDispatchQueueLabel: String = "background"

    static func getThemeIndex() -> Int {
        var index = 0
        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    index = options.themeIndex
                }
            }
        }
        return index
    }

    static func getBadgeOption() -> Bool {
        var badge = true
        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    badge = options.badge
                }
            }
        }
        return badge
    }

    static func getTime(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let defaultTimeStrings = ["07:00 AM", "12:00 PM", "5:00 PM", "9:00 PM"]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short

        if let setTime = timeOption {
            time = setTime
        } else {
            time = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
        }

        return time
    }

    static func getHour(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: date)
        return Int(hour)!
    }

    static func getMinute(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let minutes = dateFormatter.string(from: date)
        return Int(minutes)!
    }

    static func getOptionHour(segment: Int) -> Int {
        var hour = Int()
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    switch segment {
                    case 1:
                        hour = options.afternoonHour
                    case 2:
                        hour = options.eveningHour
                    case 3:
                        hour = options.nightHour
                    default:
                        hour = options.morningHour
                    }
                }
            }
        }
        return hour
    }

    static func getOptionMinute(segment: Int) -> Int {
        var minute = Int()
        DispatchQueue(label: Items.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
                switch segment {
                case 1:
                    minute = (options?.afternoonMinute)!
                case 2:
                    minute = (options?.eveningMinute)!
                case 3:
                    minute = (options?.nightMinute)!
                default:
                    minute = (options?.morningMinute)!
                }
            }
        }
        return minute
    }

    static func getSegmentNotification(segment: Int) -> Bool {
        var enabled = false
        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    switch segment {
                    case 1:
                        enabled = options.afternoonNotificationsOn
                    case 2:
                        enabled = options.eveningNotificationsOn
                    case 3:
                        enabled = options.nightNotificationsOn
                    default:
                        enabled = options.morningNotificationsOn
                    }
                }
            }
        }
        return enabled
    }
    
    static func setSegmentNotification(segment: Int, bool: Bool) {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool{
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    do {
                        try realm.write {
                            switch segment {
                            case 1:
                                options.afternoonNotificationsOn = bool
                            case 2:
                                options.eveningNotificationsOn = bool
                            case 3:
                                options.nightNotificationsOn = bool
                            default:
                                options.morningNotificationsOn = bool
                            }
                        }
                    } catch {
                        fatalError("\(#function): failed to set segment notification")
                    }
                }
            }
        }
    }

    static func getCurrentSegmentFromTime() -> Int {
        let afternoon = Calendar.autoupdatingCurrent.date(bySettingHour: Options.getOptionHour(segment: 1), minute: Options.getOptionMinute(segment: 1), second: 0, of: Date())
        let evening = Calendar.autoupdatingCurrent.date(bySettingHour: Options.getOptionHour(segment: 2), minute: Options.getOptionMinute(segment: 2), second: 0, of: Date())
        let night = Calendar.autoupdatingCurrent.date(bySettingHour: Options.getOptionHour(segment: 3), minute: Options.getOptionMinute(segment: 3), second: 0, of: Date())

        var currentSegment = 0

        switch Date() {
        case _ where Date() < afternoon!:
            currentSegment = 0
        case _ where Date() < evening!:
            currentSegment = 1
        case _ where Date() < night!:
            currentSegment = 2
        case _ where Date() > night!:
            currentSegment = 3
        default:
            currentSegment = 3
        }
        // print("getCurrentSegmentFromTime: \(currentSegment)")
        return currentSegment
    }

    static func getDateFromComponents(hour: Int, minute: Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.calendar = Calendar.autoupdatingCurrent
        dateComponent.timeZone = TimeZone.autoupdatingCurrent
        dateComponent.hour = hour
        dateComponent.minute = minute
        return dateComponent.date!
    }

    static func getDarkModeStatus() -> Bool {
        var darkMode = false
        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    darkMode = options.darkMode
                }
            }
        }
        return darkMode
    }

    static func setDarkMode(_ bool: Bool) {
        #if DEBUG
            print("Setting dark mode to: \(bool)")
        #endif
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    print("Options UUID: \(options.optionsKey)")
                    do {
                        try realm.write {
                            options.darkMode = bool
                        }
                    } catch {
                        fatalError("Failed to save dark mode: \(error)")
                    }
                }
            }
        }
    }

    static func getSegmentTimeString(segment: Int) -> String {
        var timeString: String = ""
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
                var timeOption = DateComponents()
                timeOption.calendar = Calendar.autoupdatingCurrent
                timeOption.timeZone = TimeZone.autoupdatingCurrent

                switch segment {
                case 1:
                    timeOption.hour = options?.afternoonHour
                    timeOption.minute = options?.afternoonMinute
                case 2:
                    timeOption.hour = options?.eveningHour
                    timeOption.minute = options?.eveningMinute
                case 3:
                    timeOption.hour = options?.nightHour
                    timeOption.minute = options?.nightMinute
                default:
                    timeOption.hour = options?.morningHour
                    timeOption.minute = options?.morningMinute
                }

                timeString = DateFormatter.localizedString(from: timeOption.date!, dateStyle: .none, timeStyle: .short)
            }
        }
        return timeString
    }
    
    static func setSelectedIndex(index: Int) {
        DispatchQueue(label: Options.realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    do {
                        try realm.write {
                            options.selectedIndex = index
                        }
                    } catch {
                        fatalError("\(#function): failed to save index")
                    }
                }
            }
        }
    }
    
    static func getSelectedIndex() -> Int {
        var index = 0
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool{
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
                    index = options.selectedIndex
                }
            }
        }
        return index
    }
}

extension Options: CKRecordConvertible {
    var isDeleted: Bool {
        return false
    }

    // Yep, leave it blank!
}

extension Options: CKRecordRecoverable {
    // Leave it blank, too.
}
