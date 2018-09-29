//
//  Items.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import Foundation
import RealmSwift

class Items: Object {
    @objc dynamic var title: String?
    @objc dynamic var dateModified: Date?
    @objc dynamic var segment: Int = 0
    //@objc dynamic var owner: Segments? // to-one relationships must be optional
}
