////
////  Themes.swift
////  Routines
////
////  Created by Donavon Buchanan on 11/14/18.
////  Copyright © 2018 Donavon Buchanan. All rights reserved.
////
//
// import Foundation
// import RealmSwift
////import SwiftTheme
// import UIKit
//
// enum Themes: Int {
//    case morningLight = 0
//    case afternoonLight = 1
//    case eveningLight = 2
//    case nightLight = 3
//
//    case morningDark = 4
//    case afternoonDark = 5
//    case eveningDark = 6
//    case nightDark = 7
//
//    case monochromeDark = 8
//
//    static var current: Themes {
//        Themes(rawValue: ThemeManager.currentThemeIndex)!
//    }
//
//    static var before = Themes.morningLight
//
//    // MARK: Switch Themes
//
//    static func switchTo(theme: Themes) {
//        before = current
//        ThemeManager.setTheme(index: theme.rawValue)
//    }
//
//    // MARK: Switch Dark
//

//    static func isDarkMode() -> Bool {
//        (Options.getDarkModeStatus())
//    }
//
//    // MARK: Save & Restore
//
////    static func restoreLastTheme() {
////        switchTo(theme: Themes(rawValue: Options.getThemeIndex())!)
////    }
//

////    static func saveLastTheme() {
////        let realmDispatchQueueLabel: String = "background"
////        DispatchQueue(label: realmDispatchQueueLabel).sync {
////            autoreleasepool {
////                let realm = try! Realm()
////                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
////                do {
////                    try realm.write {
////                        options?.themeIndex = ThemeManager.currentThemeIndex
////                    }
////                } catch {
////                    // print("failed to save theme index")
////                }
////            }
////        }
////    }
// }
