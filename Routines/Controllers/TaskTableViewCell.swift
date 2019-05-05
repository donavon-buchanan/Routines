//
//  TaskTableViewCell.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/23/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet var cellTitleLabel: UILabel!
    @IBOutlet var cellSubtitleLabel: UILabel!
    @IBOutlet var repeatLabel: UILabel!
    // @IBOutlet var cellIndicatorImage: UIImageView!

    // Changing this to let causes issue with making the view vanish
    var barView = UIView()
    var backgroundBarView = UIView()

    func configColorBar(segment: Int?) {
        var segmentColor: UIColor {
            switch segment {
            case 0:
                return UIColor(rgba: "#f47645", defaultColor: .red)
            case 1:
                return UIColor(rgba: "#26baee", defaultColor: .red)
            case 2:
                return UIColor(rgba: "#62a388", defaultColor: .red)
            case 3:
                return UIColor(rgba: "#645be7", defaultColor: .red)
            default:
                return .clear
            }
        }

        // Show colored bar based on segment when viewing all tasks
        barView.tag = 2
        barView.frame = CGRect(x: 0, y: 0, width: 7, height: frame.height)
        barView.backgroundColor = segmentColor
        addSubview(barView)

        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.theme_backgroundColor = GlobalPicker.backgroundColor

        // Have to set up the same for the background view during selection
        backgroundBarView.frame = CGRect(x: 0, y: 0, width: 7, height: frame.height)
        backgroundBarView.tag = 2
        backgroundBarView.backgroundColor = segmentColor
        selectedBackgroundView?.addSubview(backgroundBarView)

        cellTitleLabel.theme_textColor = GlobalPicker.cellTextColors
        theme_backgroundColor = GlobalPicker.backgroundColor
    }
}
