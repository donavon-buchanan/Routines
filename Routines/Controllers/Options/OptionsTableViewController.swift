//
//  OptionsTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

class OptionsTableViewController: UITableViewController {
    
    @IBOutlet weak var morningSwitch: UISwitch!
    @IBOutlet weak var afternoonSwitch: UISwitch!
    @IBOutlet weak var eveningSwitch: UISwitch!
    @IBOutlet weak var nightSwitch: UISwitch!
    
    @IBAction func notificationSwitchToggled(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            print("Morning Switch Toggled \(sender.isOn)")
        case 1:
            print("Afternoon Switch Toggled \(sender.isOn)")
        case 2:
            print("Evening Switch Toggled \(sender.isOn)")
        case 3:
            print("Night Switch Toggled \(sender.isOn)")
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 4
        case 2:
            numberOfRows = 1
        default:
            numberOfRows = 0
        }
        
        return numberOfRows
    }
    
    //Make the full width of the cell toggle the switch along with typical haptic
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                print("Tapped Morning Cell")
                self.morningSwitch.setOn(!self.morningSwitch.isOn, animated: true)
                print("Morning switch is now set to: \(morningSwitch.isOn)")
                haptic.impactOccurred()
            case 1:
                print("Tapped Afternoon Cell")
                self.afternoonSwitch.setOn(!self.afternoonSwitch.isOn, animated: true)
                print("Afternoon switch is now set to: \(afternoonSwitch.isOn)")
                haptic.impactOccurred()
            case 2:
                print("Tapped Evening Cell")
                self.eveningSwitch.setOn(!self.eveningSwitch.isOn, animated: true)
                print("Evening switch is now set to: \(eveningSwitch.isOn)")
                haptic.impactOccurred()
            case 3:
                print("Tapped Night Cell")
                self.nightSwitch.setOn(!self.nightSwitch.isOn, animated: true)
                print("Night switch is now set to: \(nightSwitch.isOn)")
                haptic.impactOccurred()
            default:
                break
            }
        }
    }

    //TODO: Add Notifications toggles
    //TODO: Add About section with version + build number

}
