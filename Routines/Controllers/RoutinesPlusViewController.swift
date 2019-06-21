//
//  RoutinesPlusViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/24/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import SwiftMessages
import SwiftTheme
import UIKit

class RoutinesPlusViewController: UIViewController {
    @IBOutlet var routinesPlusLabel: UILabel!
    @IBOutlet var routinesLabelPlusSymbol: UILabel!

//    @IBOutlet var yearlyDescriptionLabel: UILabel!
//    @IBOutlet var monthlyDescriptionLabel: UILabel!

    @IBOutlet var paymentButtons: [UIButton]!

//    @IBOutlet var monthlyButton: UIButton!
//    @IBOutlet var yearlyButton: UIButton!
    @IBOutlet var lifetimeButton: UIButton!

    @IBOutlet var restoreButton: UIButton!

    @IBOutlet var lifetimeTermsLabel: UILabel!
//    @IBOutlet var subscriptionTermsLabel: UILabel!

    @IBOutlet var privacyPolicyButton: UIButton!
    @IBOutlet var termsOfServiceButton: UIButton!

    @IBOutlet var textLabelCollection: [UILabel]!

    @IBAction func restoreButtonTapped(_: UIButton) {
        restorePurchase()
    }

//    @IBAction func monthlyButtonTapped(_: UIButton) {
//        purchase(purchase: .monthly)
//    }
//
//    @IBAction func yearlyButtonTapped(_: UIButton) {
//        purchase(purchase: .yearly)
//    }

    @IBAction func lifetimeButtonTapped(_: UIButton) {
        purchase(purchase: .lifetime)
    }

    @IBOutlet var policyButtons: [UIButton]!

    @IBAction func privacyPolicyButtonTapped(_: UIButton) {
        guard let url = URL(string: "https://donavon.app/privacy-policy/") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func termsOfServiceButtonTapped(_: UIButton) {
        guard let url = URL(string: "https://donavon.app/tos/") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getPrices()
        printDebug("routines plus view loaded")
        // Do stuff
        setUpUI()
    }

//    var monthlyPrice = ""
//    var monthlySubtext: String {
//        return "1 week free trial, then \(monthlyPrice) / mo. after the trial has ended"
//    }
//
//    var yearlyPrice = ""
//    var yearlySubtext: String {
//        return "2 week free trial, then \(yearlyPrice) / yr. after the trial has ended \n(12 months at \(twelveMonthPrice) / mo. Save 50%)"
//    }

    var lifetimePrice = ""

//    var twelveMonthPrice: String {
//        let priceString = yearlyPrice.dropFirst()
//        let priceDouble = Double(priceString)
//        guard let currencySymbol = yearlyPrice.first else { return "$0.49" }
//        if let monthlyBreakdown = priceDouble {
//            let localMonthly = monthlyBreakdown / 12
//            var localMonthlyString = localMonthly.regularPrice
//            localMonthlyString = "\(localMonthlyString!.dropFirst())"
//            localMonthlyString = "\(currencySymbol)\(localMonthlyString!)"
//            return localMonthlyString ?? "$0.49"
//        } else {
//            return "$0.49"
//        }
//    }

//    var subscriptionTermsString: String {
//        return "For new subscribers, monthly subscription includes a 1 week free trial, or 2 weeks for the yearly subscription. During your free trial period, if the subscription is canceled, any unused portion of the free trial will be forfeited. At the end of your free trial, your Apple ID account will be billed \(monthlyPrice) for monthly subscription, or \(yearlyPrice) for yearly subscription unless your subscription is canceled at least 24 hours before the end of the free trial period. If you continue your subscription, your account will automatically be charged for renewal unless canceled at least 24 hours prior to the end of the current subscription period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase."
//    }

    func getPrices() {
        AppDelegate.productInfo?.retrievedProducts.forEach { product in
//            if product.productIdentifier == RegisteredPurchase.monthly.rawValue {
//                monthlyPrice = product.localizedPrice ?? "Failed to fetch price"
//            } else if product.productIdentifier == RegisteredPurchase.yearly.rawValue {
//                yearlyPrice = product.localizedPrice ?? "Failed to fetch price"
//            } else
            if product.productIdentifier == RegisteredPurchase.lifetime.rawValue {
                lifetimePrice = product.localizedPrice ?? "Failed to fetch price"
            }
        }
    }

    func setButtonText() {
        printDebug("setting prices on buttons")
//        monthlyButton.setTitle("\(monthlyPrice) / Month", for: .normal)
//        yearlyButton.setTitle("\(yearlyPrice) / Year", for: .normal)
        lifetimeButton.setTitle("\(lifetimePrice) / Lifetime", for: .normal)

//        monthlyDescriptionLabel.text = monthlySubtext
//        yearlyDescriptionLabel.text = yearlySubtext
    }

    func setUpUI() {
        routinesLabelPlusSymbol.theme_textColor = GlobalPicker.barTextColor
        routinesPlusLabel.theme_textColor = GlobalPicker.barTextColor

        routinesLabelPlusSymbol.layer.theme_shadowColor = GlobalPicker.shadowColor
        routinesLabelPlusSymbol.layer.shadowRadius = 7
        routinesLabelPlusSymbol.layer.shadowOpacity = 1
        routinesLabelPlusSymbol.layer.shadowOffset = CGSize(width: 0, height: 0)
        routinesLabelPlusSymbol.layer.masksToBounds = false

        paymentButtons.forEach { button in
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 12
            button.theme_backgroundColor = GlobalPicker.barTextColor
        }

        let policyColor = UIColor(red: 0.05, green: 0.30, blue: 0.57, alpha: 1.00)
        policyButtons.forEach { button in
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 20
            button.backgroundColor = policyColor
        }

//        yearlyButton.layer.theme_shadowColor = GlobalPicker.shadowColor
//        yearlyButton.layer.shadowRadius = 16
//        yearlyButton.layer.shadowOpacity = 1
//        yearlyButton.layer.shadowOffset = CGSize(width: 0, height: 0)
//        yearlyButton.layer.masksToBounds = false

        restoreButton.theme_setTitleColor(GlobalPicker.barTextColor, forState: .normal)

        setButtonText()

//        subscriptionTermsLabel.text = subscriptionTermsString

        view.theme_backgroundColor = GlobalPicker.backgroundColor

        textLabelCollection.forEach { label in
            label.theme_textColor = GlobalPicker.cellTextColors
        }
    }
}
