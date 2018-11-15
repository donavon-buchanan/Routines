//
//  GlobalPicker.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/14/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import SwiftTheme

enum GlobalPicker {
    static let backgroundColor: ThemeColorPicker = ["#FFFDF7", "#fff", "#FFF7F1", "#222831", "#000", "#000", "#000", "#000", "#000"]
    static let barTintColor: ThemeColorPicker = ["#FFFDF7", "#fff", "#FFF7F1", "#222831", "#000", "#000", "#000", "#000", "#000"]
    
    static let textColor: ThemeColorPicker = ["#f47645", "#26baee", "#62a388", "#7971ea", "#f47645", "#26baee", "#62a388", "#5454c5", "#FFF"]
    static let barTextColors : [String] = ["#f47645", "#26baee", "#62a388", "#7971ea", "#f47645", "#26baee", "#62a388", "#5454c5", "#FFF"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    
    static let barStyle = ThemeBarStylePicker.pickerWithStyles([.default, .default, .default, .black, .black, .black, .black, .black, .black])
    
    static let cellTextColors: ThemeColorPicker = ["#000", "#000", "#000", "#fff", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF"]
    static let cellBackground: ThemeColorPicker = ["#fff", "#F5F5F5", "#FFFAF6", "#2D3541", "#000", "#000", "#000", "#000", "#000"]
    
    static let gear = ThemeImagePicker(arrayLiteral: "gear", "gear", "gear", "gear", "gear-white", "gear-white", "gear-white", "gear-white", "gear-white")
    static let morning = ThemeImagePicker(arrayLiteral: "morning", "morning", "morning", "morning", "morning-white", "morning-white", "morning-white", "morning-white", "morning-white")
    static let afternoon = ThemeImagePicker(arrayLiteral: "afternoon", "afternoon", "afternoon", "afternoon", "afternoon-white", "afternoon-white", "afternoon-white", "afternoon-white", "afternoon-white")
    static let evening = ThemeImagePicker(arrayLiteral: "evening", "evening", "evening", "evening", "evening-white", "evening-white", "evening-white", "evening-white", "evening-white")
    static let night = ThemeImagePicker(arrayLiteral: "night", "night", "night", "night", "night-white", "night-white", "night-white", "night-white", "night-white")
}
