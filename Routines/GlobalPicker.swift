//
//  GlobalPicker.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/14/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import SwiftTheme

enum GlobalPicker {
    static let backgroundColor: ThemeColorPicker = ["#fff", "#fff", "#fff", "#fff", "#000", "#000", "#000", "#000", "#000"]
    static let barTintColor: ThemeColorPicker = ["#fff", "#fff", "#fff", "#fff", "#000", "#000", "#000", "#000", "#000"]
    static let tabBarTintColor: ThemeColorPicker = ["#fff", "#fff", "#fff", "#fff", "#000", "#000", "#000", "#000", "#000"]
    static let purchaseTitleColor = ThemeColorPicker.pickerWithColors(["#645be7", "#645be7", "#645be7", "#645be7", "#645be7", "#645be7", "#645be7", "#645be7", "#645be7"])

    static let textColor: ThemeColorPicker = ["#f47645", "#26baee", "#62a388", "#645be7", "#f47645", "#26baee", "#62a388", "#645be7", "#FFF"]
    static let barTextColors: [String] = ["#f47645", "#26baee", "#62a388", "#645be7", "#f47645", "#26baee", "#62a388", "#645be7", "#FFF"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    static let shadowColor = ThemeCGColorPicker.pickerWithColors(barTextColors)

    static let switchTintColor = ThemeColorPicker.pickerWithColors(["#f47645", "#26baee", "#62a388", "#645be7", "#f47645", "#26baee", "#62a388", "#645be7", "#BBB"])

    static let barStyle = ThemeBarStylePicker.pickerWithStyles([.default, .default, .default, .default, .black, .black, .black, .black, .black])

    static let keyboardStyle = ThemeKeyboardAppearancePicker.pickerWithStyles([.default, .default, .default, .default, .dark, .dark, .dark, .dark, .dark])

    static let cellTextColors: ThemeColorPicker = ["#000", "#000", "#000", "#000", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF"]
    static let cellBackground: ThemeColorPicker = ["#F8F8F8", "#F8F8F8", "#F8F8F8", "#F8F8F8", "#181818", "#181818", "#181818", "#181818", "#181818"]
    static let cellSeparator: ThemeColorPicker = ["#e4e4e4", "#e4e4e4", "#e4e4e4", "#e4e4e4", "#464646", "#464646", "#464646", "#464646", "#464646"]
    static let cellIndicatorTint = ThemeColorPicker.pickerWithColors(["#CCC", "#CCC", "#CCC", "#CCC", "#606060", "#606060", "#606060", "#606060", "#606060"])

    static let textInputBackground: ThemeColorPicker = ["#fff", "#fff", "#fff", "#fff", "#393e46", "#393e46", "#393e46", "#393e46", "#393e46"]

    static let gear = ThemeImagePicker(arrayLiteral: "gear", "gear", "gear", "gear-white", "gear-white", "gear-white", "gear-white", "gear-white", "gear-white")
    static let morning = ThemeImagePicker(arrayLiteral: "morning", "morning", "morning", "morning-white", "morning-white", "morning-white", "morning-white", "morning-white", "morning-white")
    static let afternoon = ThemeImagePicker(arrayLiteral: "afternoon", "afternoon", "afternoon", "afternoon-white", "afternoon-white", "afternoon-white", "afternoon-white", "afternoon-white", "afternoon-white")
    static let evening = ThemeImagePicker(arrayLiteral: "evening", "evening", "evening", "evening-white", "evening-white", "evening-white", "evening-white", "evening-white", "evening-white")
    static let night = ThemeImagePicker(arrayLiteral: "night", "night", "night", "night-white", "night-white", "night-white", "night-white", "night-white", "night-white")
}
