//
//  GlobalPicker.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/14/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import SwiftTheme

enum GlobalPicker {
    static let backgroundColor: ThemeColorPicker = ["#fff", "#fff", "#fff", "#fff", "#292b38", "#292b38", "#292b38", "#292b38", "#292b38"]
    static let textColor: ThemeColorPicker = ["#000", "#000", "#000", "#000", "#ECF0F1", "#ECF0F1", "#ECF0F1", "#ECF0F1", "#ECF0F1"]
    
    static let barTextColors = ["#000", "#000", "#000", "#000", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    static let barTintColor: ThemeColorPicker = ["#EB4F38", "#F4C600", "#56ABE4", "#01040D", "#01040D", "#01040D", "#01040D", "#01040D", "#01040D"]
}
