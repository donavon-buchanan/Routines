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
    @IBOutlet var paymentTermsLabel: UILabel!
    @IBOutlet var paymentScrollView: UIScrollView!
    @IBOutlet var paymentStackView: UIStackView!
    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var gradientView: UIView!

    @IBOutlet var routinesPlusLabel: UILabel!
    @IBOutlet var routinesLabelPlusSymbol: UILabel!
    
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var yearlyButton: UIButton!
    @IBOutlet weak var lifetimeButton: UIButton!
    
    @IBAction func monthlyAction(_ sender: UIButton) {
        print(sender)
    }
    @IBAction func yearlyAction(_ sender: UIButton) {
        print(sender)
    }
    @IBAction func lifetimeAction(_ sender: UIButton) {
        print(sender)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            print("routines plus view loaded")
        #endif
        // Do stuff
        setUpUI()
    }

    func setUpUI() {
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.5, 1]
        gradientView.layer.mask = gradient

        let windowHeight = UIScreen.main.bounds.height

        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            preferredContentSize = .init(width: 0, height: windowHeight * 0.6)
        default:
            preferredContentSize = .init(width: 0, height: windowHeight * 0.9)
        }

        paymentScrollView.contentInset.bottom = 40

        let titleColor = UIColor(rgba: "#645be7", defaultColor: .white)
        let shadowColor = UIColor(rgba: "#645be7", defaultColor: .white)
        routinesLabelPlusSymbol.textColor = titleColor
        routinesPlusLabel.textColor = titleColor
        routinesLabelPlusSymbol.layer.shadowColor = shadowColor.cgColor
        routinesLabelPlusSymbol.layer.shadowRadius = 7
        routinesLabelPlusSymbol.layer.shadowOpacity = 1
        routinesLabelPlusSymbol.layer.shadowOffset = CGSize(width: 0, height: 0)
        routinesLabelPlusSymbol.layer.masksToBounds = false
        
        
    }
}
