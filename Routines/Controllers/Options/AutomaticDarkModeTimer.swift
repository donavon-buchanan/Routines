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
        #if DEBUG
            print(#function)
        #endif
        if Options.getAutomaticDarkModeStatus() {
            guard let startTime = Options.getAutomaticDarkModeStartTime() else { return }
            guard let endTime = Options.getAutomaticDarkModeEndTime() else { return }
            #if DEBUG
                print("Current Generic Time: \(Options.getCurrentGenericDate())")
                print("startTime: \(startTime)")
                print("endTime: \(endTime)")
            #endif
            if Options.getCurrentGenericDate() >= startTime || Options.getCurrentGenericDate() <= endTime {
                Options.setDarkMode(true)
            } else {
                Options.setDarkMode(false)
            }
        }
    }
}
