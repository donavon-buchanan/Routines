//
//  AlertsController.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/11/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import IceCream
import SwiftMessages
import UIKit

class SwiftMessagesAlertsController: UIView {
    let view = MessageView.viewFromNib(layout: .centeredView)

    func showAlert(title: String, body: String?) {
        SwiftMessages.defaultConfig.presentationStyle = .center
        SwiftMessages.defaultConfig.duration = .forever
        SwiftMessages.defaultConfig.interactiveHide = false
        SwiftMessages.defaultConfig.dimMode = .blur(style: .dark, alpha: 1, interactive: false)
        SwiftMessages.defaultConfig.dimModeAccessibilityLabel = "Please Wait"

        // Theme message elements with the warning style.
        // view.configureTheme(.info)

        // Add a drop shadow.
        view.configureDropShadow()
        view.button?.isHidden = true

        // Set message title, body, and icon.
        view.configureContent(title: title, body: body ?? "", iconText: "")
        view.titleLabel?.textColor = .black
        view.bodyLabel?.textColor = .black

        perform(#selector(tooLongMessage), with: nil, afterDelay: 15)

        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10

        SwiftMessages.show(view: view)
    }

    func dismissAlert() {
        SwiftMessages.hide()
    }

    @objc func tooLongMessage() {
        view.bodyLabel?.text = """
        Looks like this is taking a while.
        Please check your internet connection.
        I'll keep trying.
        """
    }
}
