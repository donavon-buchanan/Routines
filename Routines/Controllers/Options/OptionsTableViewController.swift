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
    
    @IBOutlet weak var morningSubLabel: UILabel!
    @IBOutlet weak var afternoonSubLabel: UILabel!
    @IBOutlet weak var eveningSubLabel: UILabel!
    @IBOutlet weak var nightSubLabel: UILabel!
    
    
    @IBAction func notificationSwitchToggled(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            print("Morning Switch Toggled \(sender.isOn)")
            updateNotificationOptions()
        case 1:
            print("Afternoon Switch Toggled \(sender.isOn)")
            updateNotificationOptions()
        case 2:
            print("Evening Switch Toggled \(sender.isOn)")
            updateNotificationOptions()
        case 3:
            print("Night Switch Toggled \(sender.isOn)")
            updateNotificationOptions()
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //loadOptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOptions()
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
                updateNotificationOptions()
                haptic.impactOccurred()
            case 1:
                print("Tapped Afternoon Cell")
                self.afternoonSwitch.setOn(!self.afternoonSwitch.isOn, animated: true)
                print("Afternoon switch is now set to: \(afternoonSwitch.isOn)")
                updateNotificationOptions()
                haptic.impactOccurred()
            case 2:
                print("Tapped Evening Cell")
                self.eveningSwitch.setOn(!self.eveningSwitch.isOn, animated: true)
                print("Evening switch is now set to: \(eveningSwitch.isOn)")
                updateNotificationOptions()
                haptic.impactOccurred()
            case 3:
                print("Tapped Night Cell")
                self.nightSwitch.setOn(!self.nightSwitch.isOn, animated: true)
                print("Night switch is now set to: \(nightSwitch.isOn)")
                updateNotificationOptions()
                haptic.impactOccurred()
            default:
                break
            }
        }
    }

    //MARK: - Options Realm
    
    //Options Properties
    let optionsRealm = try! Realm()
    var optionsObject: Options?
    //var firstItemAdded: Bool?
    let optionsKey = "optionsKey"
    
    //Load Options
    func loadOptions() {
        optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey)
    }
    
    func updateNotificationOptions() {
        do {
            try self.optionsRealm.write {
                print("saving notification option")
                self.optionsObject?.morningNotificationsOn = morningSwitch.isOn
                self.optionsObject?.afternoonNotificationsOn = afternoonSwitch.isOn
                self.optionsObject?.eveningNotificationsOn = eveningSwitch.isOn
                self.optionsObject?.nightNotificationsOn = nightSwitch.isOn
            }
        } catch {
            print("failed to update notification saved bools")
        }
    }
    
    func setUpUI() {
        print("Setting up UI")
        //Set Switches
        morningSwitch.setOn(getNotificationBool(notificationOption: optionsObject?.morningNotificationsOn), animated: false)
        afternoonSwitch.setOn(getNotificationBool(notificationOption: optionsObject?.afternoonNotificationsOn), animated: false)
        eveningSwitch.setOn(getNotificationBool(notificationOption: optionsObject?.eveningNotificationsOn), animated: false)
        nightSwitch.setOn(getNotificationBool(notificationOption: optionsObject?.nightNotificationsOn), animated: false)
        
        //Set Sub Labels
        morningSubLabel.text = getOptionTimes(timePeriod: 0, timeOption: optionsObject?.morningStartTime)
        afternoonSubLabel.text = getOptionTimes(timePeriod: 1, timeOption: optionsObject?.afternoonStartTime)
        eveningSubLabel.text = getOptionTimes(timePeriod: 2, timeOption: optionsObject?.eveningStartTime)
        nightSubLabel.text = getOptionTimes(timePeriod: 3, timeOption: optionsObject?.nightStartTime)
    }
    
    func getNotificationBool(notificationOption: Bool?) -> Bool {
        var isOn = false
        if let notificationIsOn = notificationOption {
            isOn = notificationIsOn
        }
        return isOn
    }
    
    func getOptionTimes(timePeriod: Int, timeOption: Date?) -> String {
        var time: String = " "
        let periods = ["morning", "afternoon", "evening", "night"]
        let defaultTimeStrings = ["07:00 AM", "12:00 PM", "5:00 PM", "9:00 PM"]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        if let dateTime = timeOption {
            
            time = "Your \(periods[timePeriod]) begins at \(dateFormatter.string(from: dateTime))"
        } else {
            
            let defaultTime = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
            
            time = "Your \(periods[timePeriod]) begins at \(dateFormatter.string(from: defaultTime))"
        }
        
        return time
    }

}
