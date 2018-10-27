//
//  Options.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/29/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift

class Options: Object {
    @objc dynamic var segment0StartTime: Date?
    @objc dynamic var segment1StartTime: Date?
    @objc dynamic var segment2StartTime: Date?
    @objc dynamic var segment3StartTime: Date?
    
    @objc dynamic var firstItemAdded: Bool = false
    
}
