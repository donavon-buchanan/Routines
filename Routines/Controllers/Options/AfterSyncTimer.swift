//
//  afterSyncTimer.swift
//  Routines
//
//  Created by Donavon Buchanan on 5/8/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation

class AfterSyncTimer {
    var timer: Timer?

    func startTimer() {
        guard timer == nil else { return }
        #if DEBUG
            print("afterSyncTimer started")
        #endif
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(doRefresh), userInfo: nil, repeats: false)
    }

    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
        #if DEBUG
            print("afterSyncTimer invalidated")
        #endif
    }

    @objc func doRefresh() {
        AppDelegate.refreshAndUpdate()
    }
}
