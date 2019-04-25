//
//  iAPSegue.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/24/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import SwiftMessages
import UIKit

class iAPSegue: SwiftMessagesSegue {
    public override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)

        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            configure(layout: .centered)
        default:
            configure(layout: .bottomTab)
        }

        if Options.getDarkModeStatus() {
            dimMode = .blur(style: .dark, alpha: 0.9, interactive: true)
            messageView.configureNoDropShadow()
        } else {
            dimMode = .blur(style: .regular, alpha: 0.9, interactive: true)
            messageView.configureDropShadow()
        }
    }
}
