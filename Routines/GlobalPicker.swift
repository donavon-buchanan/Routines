//
//  GlobalPicker.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/14/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import SwiftTheme

enum GlobalPicker {
    static let backgroundColor: ThemeColorPicker = ["#fbeed7", "#fff", "#fff", "#fff", "#000", "#000", "#000", "#000", "#000"]
    static let textColor: ThemeColorPicker = ["#f47645", "#000", "#000", "#000", "#f47645", "#ECF0F1", "#ECF0F1", "#ECF0F1", "#ECF0F1"]
    
    static let barTextColors = ["#f47645", "#000", "#000", "#000", "#f47645", "#FFF", "#FFF", "#FFF", "#FFF"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    static let barTintColor: ThemeColorPicker = ["#fbeed7", "#F4C600", "#56ABE4", "#01040D", "#000", "#000", "#000", "#000", "#000"]
    
    static let cellTextColors: ThemeColorPicker = ["#000", "#000", "#000", "#000", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF"]
    static let cellBackground: ThemeColorPicker = ["#F8E6C7", "#fff", "#fff", "#fff", "#000", "#000", "#000", "#000", "#000"]
}
