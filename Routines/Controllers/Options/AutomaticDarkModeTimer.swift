//
//  automaticDarkModeTimer.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/6/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation

class AutomaticDarkModeTimer {
    var timer: Timer?

    func startTimer() {
        guard timer == nil else { return }
        automaticDarkModeCheck()
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(automaticDarkModeCheck), userInfo: nil, repeats: true)
        #if DEBUG
            print("automatic dark mode timer started")
        #endif
    }

    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
        #if DEBUG
            print("automatic dark mode timer invalidated")
        #endif
    }

    @objc func automaticDarkModeCheck() {
        Options.automaticDarkModeCheck()
    }
}
