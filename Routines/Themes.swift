//
//  Themes.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/14/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftTheme

// Get the default Realm
private let realm = try! Realm()
private let optionsKey = "optionsKey"
private let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)

enum Themes: Int {
    case morningLight = 0
    case afternoonLight = 1
    case eveningLight = 2
    case nightLight = 3

    case morningDark = 4
    case afternoonDark = 5
    case eveningDark = 6
    case nightDark = 7

    case monochromeDark = 8

    static var current: Themes {
        return Themes(rawValue: ThemeManager.currentThemeIndex)!
    }

    static var before = Themes.morningLight

    // MARK: Switch Themes

    static func switchTo(theme: Themes) {
        before = current
        ThemeManager.setTheme(index: theme.rawValue)
    }

    // MARK: Switch Dark

    // TODO: Pass in segment here
    static func isDarkMode() -> Bool {
        return (options?.darkMode)!
    }

    // MARK: Save & Restore

    static func restoreLastTheme() {
        switchTo(theme: Themes(rawValue: (options?.themeIndex)!)!)
    }

    // TODO: Get rid of this
    static func saveLastTheme() {
        let realmDispatchQueueLabel: String = "background"
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let optionsKey = "optionsKey"
                let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)
                do {
                    try realm.write {
                        options?.themeIndex = ThemeManager.currentThemeIndex
                    }
                } catch {
                    print("failed to save theme index")
                }
            }
        }
    }
}
