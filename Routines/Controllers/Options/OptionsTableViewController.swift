//
//  OptionsTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import RealmSwift
import StoreKit
import SwiftTheme
import SwiftyStoreKit
import UIKit
import UserNotifications

enum RegisteredPurchase: String {
    case lifetime = "lifetime1"
    case yearly = "routines_plus_yearly"
    case monthly = "routines_plus_monthly"
}

class OptionsTableViewController: UITableViewController {
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var switches: [UISwitch]!

    @IBOutlet var morningSwitch: UISwitch!
    @IBOutlet var afternoonSwitch: UISwitch!
    @IBOutlet var eveningSwitch: UISwitch!
    @IBOutlet var nightSwitch: UISwitch!

    @IBOutlet var morningSubLabel: UILabel!
    @IBOutlet var afternoonSubLabel: UILabel!
    @IBOutlet var eveningSubLabel: UILabel!
    @IBOutlet var nightSubLabel: UILabel!

    @IBOutlet var cloudSyncLabel: UILabel!
    @IBOutlet var cloudSyncSwitch: UISwitch!
    @IBAction func cloudSyncSwitchToggled(_ sender: UISwitch) {
        if cloudSyncSwitch.isEnabled {
            // cloudSyncSwitch.setOn(!cloudSyncSwitch.isOn, animated: true)
            Options.setCloudSync(toggle: cloudSyncSwitch.isOn)
            AppDelegate.setSync()
            if cloudSyncSwitch.isOn {
                Items.requestNotificationPermission()
                AppDelegate.syncEngine?.pushAll()
                AppDelegate.syncEngine?.pull()
                AppDelegate.refreshNotifications()
            }
        } else {
            // Show Purchase Options
            showPurchaseOptions()
        }
        #if DEBUG
            print("Cloud sync switch: \(sender.isOn)")
        #endif
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "w", modifierFlags: .init(arrayLiteral: .command), action: #selector(dismissView), discoverabilityTitle: "Exit"),
        ]
    }

    @IBAction func notificationSwitchToggled(_ sender: UISwitch) {
        switch sender.tag {
        case 1:
            Options.setSegmentNotification(segment: 1, bool: sender.isOn)
        // print("Afternoon Switch Toggled \(sender.isOn)")
        case 2:
            Options.setSegmentNotification(segment: 2, bool: sender.isOn)
        // print("Evening Switch Toggled \(sender.isOn)")
        case 3:
            Options.setSegmentNotification(segment: 3, bool: sender.isOn)
        // print("Night Switch Toggled \(sender.isOn)")
        default:
            Options.setSegmentNotification(segment: 0, bool: sender.isOn)
            // print("Morning Switch Toggled \(sender.isOn)")
        }
    }

    @IBOutlet var darkModeSwtich: UISwitch!
    @IBAction func darkModeSwitchToggled(_ sender: UISwitch) {
        Options.setDarkMode(sender.isOn)
        setAppearance(tab: Options.getSelectedIndex())
    }

    @objc func dismissView() {
        // dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "unwindToTableViewController", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Colors
        cellLabels.forEach { label in
            label.theme_textColor = GlobalPicker.cellTextColors
        }
        switches.forEach { UISwitch in
            // band-aid for graphical glitch when toggling dark mode
            UISwitch.layer.cornerRadius = 15
            UISwitch.layer.masksToBounds = true
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissView))

        tableView.theme_backgroundColor = GlobalPicker.backgroundColor
        observeOptions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
        if !Options.getPurchasedStatus() {
            getAllProductInfo(productIDs: Set(arrayLiteral: RegisteredPurchase.monthly.rawValue, RegisteredPurchase.yearly.rawValue, RegisteredPurchase.lifetime.rawValue))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // Make the full width of the cell toggle the switch along with typical haptic
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 1:
                // print("Tapped Afternoon Cell")
                let isOn = !afternoonSwitch.isOn
                afternoonSwitch.setOn(isOn, animated: true)
                //                addOrRemoveNotifications(isOn: isOn, segment: 1)
                //                // print("Afternoon switch is now set to: \(afternoonSwitch.isOn)")
                //                updateNotificationOptions(segment: 1, isOn: afternoonSwitch.isOn)
                haptic.impactOccurred()
            case 2:
                // print("Tapped Evening Cell")
                let isOn = !eveningSwitch.isOn
                eveningSwitch.setOn(isOn, animated: true)
                //                addOrRemoveNotifications(isOn: isOn, segment: 2)
                //                // print("Evening switch is now set to: \(eveningSwitch.isOn)")
                //                updateNotificationOptions(segment: 2, isOn: eveningSwitch.isOn)
                haptic.impactOccurred()
            case 3:
                // print("Tapped Night Cell")
                let isOn = !nightSwitch.isOn
                nightSwitch.setOn(isOn, animated: true)
                //                addOrRemoveNotifications(isOn: isOn, segment: 3)
                //                // print("Night switch is now set to: \(nightSwitch.isOn)")
                //                updateNotificationOptions(segment: 3, isOn: nightSwitch.isOn)
                haptic.impactOccurred()
            default:
                // print("Tapped Morning Cell")
                let isOn = !morningSwitch.isOn
                morningSwitch.setOn(isOn, animated: true)
                //                addOrRemoveNotifications(isOn: isOn, segment: 0)
                //                // print("Morning switch is now set to: \(morningSwitch.isOn)")
                //                updateNotificationOptions(segment: 0, isOn: morningSwitch.isOn)
                haptic.impactOccurred()
            }
        case 2:
            darkModeSwtich.setOn(!darkModeSwtich.isOn, animated: true)
            Options.setDarkMode(darkModeSwtich.isOn)
            setAppearance(tab: Options.getSelectedIndex())
            haptic.impactOccurred()
        case 3:
            #if DEBUG
                print("\(#function) - Case 3")
            #endif
            if cloudSyncSwitch.isEnabled {
                #if DEBUG
                    print("\(#function) - cloudSyncSwitch.isEnabled")
                #endif
                cloudSyncSwitch.setOn(!cloudSyncSwitch.isOn, animated: true)
                Options.setCloudSync(toggle: cloudSyncSwitch.isOn)
                AppDelegate.setSync()
                haptic.impactOccurred()
                if cloudSyncSwitch.isOn {
                    Items.requestNotificationPermission()
                    AppDelegate.syncEngine?.pushAll()
                    AppDelegate.syncEngine?.pull()
                    AppDelegate.refreshNotifications()
                }
            } else {
                #if DEBUG
                    print("\(#function) - Case 3 else, should show purchase options")
                #endif
                // Show Purchase Options
                showPurchaseOptions()
            }
        default:
            #if DEBUG
                print("\(#function) - Default case triggered")
            #endif
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            tableView.estimatedRowHeight = 60
            return UITableView.automaticDimension
        } else {
            return 60
        }
    }

    // MARK: - Options Realm

//    func updateNotificationOptions(segment: Int, isOn: Bool) {
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey())
//                switch segment {
//                case 1:
//                    do {
//                        try realm.write {
//                            // print("updateNotificationOptions saving")
//                            options?.afternoonNotificationsOn = isOn
//                        }
//                    } catch {
//                        // print("updateNotificationOptions failed")
//                    }
//                case 2:
//                    do {
//                        try realm.write {
//                            // print("updateNotificationOptions saving")
//                            options?.eveningNotificationsOn = isOn
//                        }
//                    } catch {
//                        // print("updateNotificationOptions failed")
//                    }
//                case 3:
//                    do {
//                        try realm.write {
//                            // print("updateNotificationOptions saving")
//                            options?.nightNotificationsOn = isOn
//                        }
//                    } catch {
//                        // print("updateNotificationOptions failed")
//                    }
//                default:
//                    do {
//                        try realm.write {
//                            // print("updateNotificationOptions saving")
//                            options?.morningNotificationsOn = isOn
//                        }
//                    } catch {
//                        // print("updateNotificationOptions failed")
//                    }
//                }
//            }
//        }
//    }

    func setUpUI() {
        morningSwitch.setOn(Options.getSegmentNotification(segment: 0), animated: false)
        afternoonSwitch.setOn(Options.getSegmentNotification(segment: 1), animated: false)
        eveningSwitch.setOn(Options.getSegmentNotification(segment: 2), animated: false)
        nightSwitch.setOn(Options.getSegmentNotification(segment: 3), animated: false)

        cloudSyncSwitch.setOn(Options.getCloudSync(), animated: false)
        cloudSyncSwitch.isEnabled = Options.getPurchasedStatus()

        darkModeSwtich.setOn(Options.getDarkModeStatus(), animated: false)

        morningSubLabel.text = Options.getSegmentTimeString(segment: 0)
        afternoonSubLabel.text = Options.getSegmentTimeString(segment: 1)
        eveningSubLabel.text = Options.getSegmentTimeString(segment: 2)
        nightSubLabel.text = Options.getSegmentTimeString(segment: 3)
    }

    func refreshUI() {
        // TODO: This should be a bit more granular
        morningSwitch.setOn(Options.getSegmentNotification(segment: 0), animated: true)
        afternoonSwitch.setOn(Options.getSegmentNotification(segment: 1), animated: true)
        eveningSwitch.setOn(Options.getSegmentNotification(segment: 2), animated: true)
        nightSwitch.setOn(Options.getSegmentNotification(segment: 3), animated: true)

        cloudSyncSwitch.setOn(Options.getCloudSync(), animated: true)
        cloudSyncSwitch.isEnabled = Options.getPurchasedStatus()

        darkModeSwtich.setOn(Options.getDarkModeStatus(), animated: true)

        morningSubLabel.text = Options.getSegmentTimeString(segment: 0)
        afternoonSubLabel.text = Options.getSegmentTimeString(segment: 1)
        eveningSubLabel.text = Options.getSegmentTimeString(segment: 2)
        nightSubLabel.text = Options.getSegmentTimeString(segment: 3)
    }

    func setAppearance(tab: Int) {
        if Options.getDarkModeStatus() {
            switch tab {
            case 1:
                Themes.switchTo(theme: .afternoonDark)
            case 2:
                Themes.switchTo(theme: .eveningDark)
            case 3:
                Themes.switchTo(theme: .nightDark)
            default:
                Themes.switchTo(theme: .morningDark)
            }
        } else {
            switch tab {
            case 1:
                Themes.switchTo(theme: .afternoonLight)
            case 2:
                Themes.switchTo(theme: .eveningLight)
            case 3:
                Themes.switchTo(theme: .nightLight)
            default:
                Themes.switchTo(theme: .morningLight)
            }
        }
    }

    // MARK: - Options

    var optionsToken: NotificationToken?

    deinit {
        optionsToken?.invalidate()
    }

    func observeOptions() {
        let realm = try! Realm()
        if let options = realm.object(ofType: Options.self, forPrimaryKey: Options.primaryKey()) {
            optionsToken = options.observe { change in
                switch change {
                case let .change(properties):
                    properties.forEach { _ in
                        self.refreshUI()
                    }
                // AppDelegate.refreshNotifications()
                case let .error(error):
                    #if DEBUG
                        print("Options observation error occurred: \(error)")
                    #endif
                case .deleted:
                    #if DEBUG
                        print("The object was deleted.")
                    #endif
                }
            }
        }
    }

    // MARK: - IAP

    var productInfo: RetrieveResults?

    func getAllProductInfo(productIDs: Set<String>) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo(productIDs) { results in
            NetworkActivityIndicatorManager.networkOperationEnded()
            self.productInfo = results
        }
    }

    func showPurchaseOptions() {
        #if DEBUG
            print("\(#function)")
        #endif
        var alertActions: [UIAlertAction] = []
        guard (productInfo?.retrievedProducts.count ?? 0) > 0 else { showFailAlert(); return }
        productInfo?.retrievedProducts.forEach { product in
            alertActions.append(UIAlertAction(title: product.localizedTitle + " : \(product.localizedPrice!)", style: .default, handler: { _ in
                self.purchase(purchase: RegisteredPurchase(rawValue: product.productIdentifier)!)
            }))
        }
        let restoreAction = UIAlertAction(title: "Restore Purchases", style: .default) { _ in
            self.restorePurchase()
        }
        alertActions.append(restoreAction)
        showProductAlert(alertActions: alertActions)
    }

    func showProductAlert(alertActions: [UIAlertAction]) {
        let alertController = UIAlertController(title: "Upgrade to Routines+", message: "Choose from Monthly or Annual subscription options, or pay once to unlock forever with the Lifetime unlock.", preferredStyle: .actionSheet)
        alertActions.forEach { action in
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func showFailAlert() {
        getAllProductInfo(productIDs: Set(arrayLiteral: RegisteredPurchase.monthly.rawValue, RegisteredPurchase.yearly.rawValue, RegisteredPurchase.lifetime.rawValue))
        let alertController = UIAlertController(title: "Connection Failure", message: "Failed to get purchase options from the App Store. Please check your internet conenction or try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
