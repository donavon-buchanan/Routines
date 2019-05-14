//
//  ThemePicker.swift
//  SwiftTheme
//
//  Created by Gesen on 16/1/25.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import Foundation

@objc public class ThemePicker: NSObject, NSCopying {
    public typealias ValueType = () -> Any?

    public var value: ValueType

    public required init(v: @escaping ValueType) {
        value = v
    }

    public func copy(with _: NSZone?) -> Any {
        return type(of: self).init(v: value)
    }
}
