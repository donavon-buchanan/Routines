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
                return UIColor(hex: "#f47645") ?? UIColor(red: 0.96, green: 0.46, blue: 0.27, alpha: 1.0)
            case 1:
                return UIColor(hex: "#26baee") ?? UIColor(red: 0.15, green: 0.73, blue: 0.93, alpha: 1.0)
            case 2:
                return UIColor(hex: "#62a388") ?? UIColor(red: 0.38, green: 0.64, blue: 0.53, alpha: 1.0)
            case 3:
                return UIColor(hex: "#645be7") ?? UIColor(red: 0.39, green: 0.36, blue: 0.91, alpha: 1.0)
            default:
                return .clear
            }
        }

        // Show colored bar based on segment when viewing all tasks
        barView.tag = 2
        barView.frame = CGRect(x: 0, y: 0, width: 7, height: 200)
        barView.backgroundColor = segmentColor
        addSubview(barView)

        selectedBackgroundView = UIView(frame: frame)
//        selectedBackgroundView?.theme_backgroundColor = GlobalPicker.backgroundColor

        // Have to set up the same for the background view during selection
        backgroundBarView.frame = CGRect(x: 0, y: 0, width: 7, height: 200)
        backgroundBarView.tag = 2
        backgroundBarView.backgroundColor = segmentColor
        selectedBackgroundView?.addSubview(backgroundBarView)

//        cellTitleLabel.theme_textColor = GlobalPicker.cellTextColors
//        theme_backgroundColor = GlobalPicker.backgroundColor
    }
}
