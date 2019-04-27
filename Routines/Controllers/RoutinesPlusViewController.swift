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

    @IBOutlet var yearlyBreakdownLabel: UILabel!

    @IBOutlet var paymentButtons: [UIButton]!

    @IBOutlet var monthlyButton: UIButton!
    @IBOutlet var yearlyButton: UIButton!
    @IBOutlet var lifetimeButton: UIButton!

    @IBOutlet var restoreButton: UIButton!
    
    @IBOutlet weak var lifetimeTermsLabel: UILabel!
    @IBOutlet weak var subscriptionTermsLabel: UILabel!
    
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termsOfServiceButton: UIButton!
    
    @IBAction func restoreButtonTapped(_: UIButton) {
        restorePurchase()
    }

    @IBAction func monthlyButtonTapped(_: UIButton) {
        purchase(purchase: .monthly)
    }

    @IBAction func yearlyButtonTapped(_: UIButton) {
        purchase(purchase: .yearly)
    }

    @IBAction func lifetimeButtonTapped(_: UIButton) {
        purchase(purchase: .lifetime)
    }
    
    @IBOutlet var policyButtons: [UIButton]!
    
    @IBAction func privacyPolicyButtonTapped(_ sender: UIButton) {
    }
    @IBAction func termsOfServiceButtonTapped(_ sender: UIButton) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getPrices()
        #if DEBUG
            print("routines plus view loaded")
        #endif
        // Do stuff
        setUpUI()
    }

    var monthlyPrice = ""
    var yearlyPrice = ""
    var lifetimePrice = ""
    var twelveMonthPrice: String {
        let priceString = yearlyPrice.dropFirst()
        let priceDouble = Double(priceString)
        guard let currencySymbol = yearlyPrice.first else { return "$0.49" }
        if let monthlyBreakdown = priceDouble {
            let localMonthly = monthlyBreakdown / 12
            var localMonthlyString = localMonthly.regularPrice
            localMonthlyString = "\(localMonthlyString!.dropFirst())"
            localMonthlyString = "\(currencySymbol)\(localMonthlyString!)"
            return localMonthlyString ?? "$0.49"
        } else {
            return "$0.49"
        }
    }

    func getPrices() {
        AppDelegate.productInfo?.retrievedProducts.forEach { product in
            if product.productIdentifier == RegisteredPurchase.monthly.rawValue {
                monthlyPrice = product.localizedPrice ?? "Failed to fetch price"
            } else if product.productIdentifier == RegisteredPurchase.yearly.rawValue {
                yearlyPrice = product.localizedPrice ?? "Failed to fetch price"
            } else if product.productIdentifier == RegisteredPurchase.lifetime.rawValue {
                lifetimePrice = product.localizedPrice ?? "Failed to fetch price"
            }
        }
    }

    func setButtonText() {
        #if DEBUG
            print("setting prices on buttons")
        #endif
        monthlyButton.setTitle("\(monthlyPrice) / Month", for: .normal)
        yearlyButton.setTitle("\(yearlyPrice) / Year", for: .normal)
        lifetimeButton.setTitle("\(lifetimePrice) / Lifetime", for: .normal)
        yearlyBreakdownLabel.text = "(12 months at \(twelveMonthPrice) / mo. Save 50%)"
    }

    func setUpUI() {
        let titleColor = UIColor(rgba: "#645be7", defaultColor: .white)
        let shadowColor = UIColor(rgba: "#645be7", defaultColor: .white)
        routinesLabelPlusSymbol.textColor = titleColor
        routinesPlusLabel.textColor = titleColor
        routinesLabelPlusSymbol.layer.shadowColor = shadowColor.cgColor
        routinesLabelPlusSymbol.layer.shadowRadius = 7
        routinesLabelPlusSymbol.layer.shadowOpacity = 1
        routinesLabelPlusSymbol.layer.shadowOffset = CGSize(width: 0, height: 0)
        routinesLabelPlusSymbol.layer.masksToBounds = false

        paymentButtons.forEach { button in
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 12
            button.backgroundColor = titleColor
        }
        
        let policyColor = UIColor(red: 0.05, green: 0.30, blue: 0.57, alpha: 1.00)
        policyButtons.forEach { button in
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 20
            button.backgroundColor = policyColor
        }
        
        yearlyButton.layer.shadowColor = shadowColor.cgColor
        yearlyButton.layer.shadowRadius = 16
        yearlyButton.layer.shadowOpacity = 1
        yearlyButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        yearlyButton.layer.masksToBounds = false

        restoreButton.setTitleColor(titleColor, for: .normal)

        setButtonText()
    }
}
