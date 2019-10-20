//
//  UIColorExtensions.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/24/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x0000_00FF) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }

    public convenience init(segment: Int) {
        switch segment {
        case 0:
            self.init(red: 0.96, green: 0.46, blue: 0.27, alpha: 1.0)
        case 1:
            self.init(red: 0.15, green: 0.73, blue: 0.93, alpha: 1.0)
        case 2:
            self.init(red: 0.38, green: 0.64, blue: 0.53, alpha: 1.0)
        case 3:
            self.init(red: 0.39, green: 0.36, blue: 0.91, alpha: 1.0)
        default:
            self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
}
