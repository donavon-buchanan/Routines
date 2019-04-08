//
//  TaskTableViewCell.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/23/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    // Can't set weak vars here. Cells won't automatically size reliably
    @IBOutlet var cellTitleLabel: UILabel!
    @IBOutlet var cellSubtitleLabel: UILabel!
    @IBOutlet var repeatLabel: UILabel!
    @IBOutlet var cellIndicatorImage: UIImageView!
}
