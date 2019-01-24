//
//  CheckableTableViewCell.swift
//  Routines
//
//  Created by Donavon Buchanan on 1/20/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

class CheckableTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
}
