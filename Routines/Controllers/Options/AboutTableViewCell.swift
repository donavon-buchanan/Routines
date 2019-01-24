//
//  AboutTableViewCell.swift
//  Routines
//
//  Created by Donavon Buchanan on 10/29/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit

class AboutTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setLabel(labelString: String) {
        textLabel?.text = labelString
    }
}
