//
//  GlobalPicker.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/14/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import SwiftTheme

enum GlobalPicker {
    static let backgroundColor: ThemeColorPicker = ["#fff", "#fff", "#fff", "#222831", "#000", "#000", "#000", "#000", "#000"]
    static let barTintColor: ThemeColorPicker = ["#fff", "#fff", "#fff", "#1C2026", "#000", "#000", "#000", "#000", "#000"]
    static let tabBarTintColor: ThemeColorPicker = ["#fff", "#fff", "#fff", "#1C2026", "#131415", "#131415", "#131415", "#131415", "#131415"]
    
    static let textColor: ThemeColorPicker = ["#f47645", "#26baee", "#62a388", "#7971ea", "#f47645", "#26baee", "#62a388", "#7971ea", "#FFF"]
    static let barTextColors : [String] = ["#f47645", "#26baee", "#62a388", "#7971ea", "#f47645", "#26baee", "#62a388", "#7971ea", "#FFF"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    
    static let switchTintColor = ThemeColorPicker.pickerWithColors(["#f47645", "#26baee", "#62a388", "#7971ea", "#f47645", "#26baee", "#62a388", "#7971ea", "#BBB"])
    
    static let barStyle = ThemeBarStylePicker.pickerWithStyles([.default, .default, .default, .black, .black, .black, .black, .black, .black])
    
    static let keyboardStyle = ThemeKeyboardAppearancePicker.pickerWithStyles([.default, .default, .default, .dark, .dark, .dark, .dark, .dark, .dark])
    
    static let cellTextColors: ThemeColorPicker = ["#000", "#000", "#000", "#fff", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF"]
    static let cellBackground: ThemeColorPicker = ["#F8F8F8", "#F8F8F8", "#F8F8F8", "#2D3541", "#181818", "#181818", "#181818", "#181818", "#181818"]
    static let cellIndicatorTint = ThemeColorPicker.pickerWithColors(["#CCC", "#CCC", "#CCC", "#606060", "#606060", "#606060", "#606060", "#606060", "#606060"])
    
    static let textInputBackground: ThemeColorPicker = ["#fff", "#fff", "#fff", "#393e46", "#393e46", "#393e46", "#393e46", "#393e46", "#393e46"]
    
    static let gear = ThemeImagePicker(arrayLiteral: "gear", "gear", "gear", "gear-white", "gear-white", "gear-white", "gear-white", "gear-white", "gear-white")
    static let morning = ThemeImagePicker(arrayLiteral: "morning", "morning", "morning", "morning-white", "morning-white", "morning-white", "morning-white", "morning-white", "morning-white")
    static let afternoon = ThemeImagePicker(arrayLiteral: "afternoon", "afternoon", "afternoon", "afternoon-white", "afternoon-white", "afternoon-white", "afternoon-white", "afternoon-white", "afternoon-white")
    static let evening = ThemeImagePicker(arrayLiteral: "evening", "evening", "evening", "evening-white", "evening-white", "evening-white", "evening-white", "evening-white", "evening-white")
    static let night = ThemeImagePicker(arrayLiteral: "night", "night", "night", "night-white", "night-white", "night-white", "night-white", "night-white", "night-white")
    
    //static let snoozeStrike = ThemeImagePicker(arrayLiteral: "snooze-strike", "snooze-strike", "snooze-strike", "snooze-dark-strike", "snooze-dark-strike", "snooze-dark-strike", "snooze-dark-strike", "snooze-dark-strike", "snooze-dark-strike")
    //static let repeats = ThemeImagePicker(arrayLiteral: "repeat", "repeat", "repeat", "repeat-dark", "repeat-dark", "repeat-dark", "repeat-dark", "repeat-dark", "repeat-dark")
    //static let anchorCell = ThemeImagePicker(arrayLiteral: "anchor-grey", "anchor-grey", "anchor-grey", "anchor-dark-grey", "anchor-dark-grey", "anchor-dark-grey", "anchor-dark-grey", "anchor-dark-grey", "anchor-dark-grey")
    //static let repeatsCell = ThemeImagePicker(arrayLiteral: "repeat-grey", "repeat-grey", "repeat-grey", "repeat-dark-grey", "repeat-dark-grey", "repeat-dark-grey", "repeat-dark-grey", "repeat-dark-grey", "repeat-dark-grey")
}
