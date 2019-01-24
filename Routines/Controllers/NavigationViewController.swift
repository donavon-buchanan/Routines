//
//  NavigationViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 11/4/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import UserNotifications

class NavigationViewController: UINavigationController, UNUserNotificationCenterDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        center.delegate = self
    }

//    let center = UNUserNotificationCenter.current()

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

//    //Notification Settings Screen
//    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
//        print("Opening settings")
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let optionsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsView") as! OptionsTableViewController
//        self.pushViewController(optionsViewController, animated: true)
//    }
}
