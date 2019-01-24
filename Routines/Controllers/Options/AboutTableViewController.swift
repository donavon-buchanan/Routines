//
//  AboutTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 10/29/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    @IBOutlet var versionNumberLabel: UILabel!

    @IBOutlet var cells: [UITableViewCell]!

    @IBOutlet var labels: [UILabel]!

    @IBOutlet var gearImage: UIImageView!
    @IBOutlet var morningImage: UIImageView!
    @IBOutlet var afternoonImage: UIImageView!
    @IBOutlet var eveningImage: UIImageView!
    @IBOutlet var nightImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        versionNumberLabel.text = setVersionNumberLabel()
        setViewBackgroundGraphic()

        cells.forEach { cell in
            cell.theme_backgroundColor = GlobalPicker.cellBackground
        }

        labels.forEach { label in
            label.theme_textColor = GlobalPicker.cellTextColors
        }

        gearImage.theme_image = GlobalPicker.gear
        morningImage.theme_image = GlobalPicker.morning
        afternoonImage.theme_image = GlobalPicker.afternoon
        eveningImage.theme_image = GlobalPicker.evening
        nightImage.theme_image = GlobalPicker.night
    }

    func setVersionNumberLabel() -> String {
        guard let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else { fatalError("Failed to get version number") }
        // print("App Version: \(String(describing: appVersion))")
        guard let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String else { fatalError("Failed to get build number") }
        // print("Build NUmber: \(buildNumber)")
        let versionString = "Version: \(appVersion), Build: \(buildNumber)"

        // return "fuck you"
        return versionString
    }

    // Set background graphic
    func setViewBackgroundGraphic() {
        let backgroundImageView = UIImageView()
        let backgroundImage = UIImage(imageLiteralResourceName: "inlay")

        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFit

        tableView.backgroundView = backgroundImageView
    }
}
