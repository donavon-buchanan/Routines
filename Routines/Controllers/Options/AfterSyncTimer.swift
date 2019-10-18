////
////  afterSyncTimer.swift
////  Routines
////
////  Created by Donavon Buchanan on 5/8/19.
////  Copyright © 2019 Donavon Buchanan. All rights reserved.
////
//
// import Foundation
//
// class AfterSyncTimer {
//    var timer: Timer?
//
//    func startTimer() {
//        DispatchQueue.main.async {
//            guard self.timer == nil else { return }
//            debugPrint("afterSyncTimer started")
//            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.doRefresh), userInfo: nil, repeats: false)
//        }
//    }
//
//    func stopTimer() {
//        guard timer != nil else { return }
//        timer?.invalidate()
//        timer = nil
//        debugPrint("afterSyncTimer invalidated")
//    }
//
//    @objc func doRefresh() {
//        debugPrint(#function)
//        AppDelegate.refreshAndUpdate()
//
//        stopTimer()
//    }
// }
