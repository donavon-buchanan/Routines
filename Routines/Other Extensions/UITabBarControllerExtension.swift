////
////  UITabBarControllerExtension.swift
////  Routines
////
////  Created by Donavon Buchanan on 11/29/18.
////  Copyright © 2018 Donavon Buchanan. All rights reserved.
////
//
// import UIKit
//
// extension UITabBarController {
//    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
//        if (tabBarIsVisible() == visible) { return }
//        let frame = self.tabBar.frame
//        let height = frame.size.height
//        let offsetY = (visible ? -height : height)
//
//        // animation
//        UIViewPropertyAnimator(duration: duration, curve: .linear) {
//            self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
////            self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
////            self.view.setNeedsDisplay()
////            self.view.layoutIfNeeded()
//            }.startAnimation()
//    }
//
//    func tabBarIsVisible() ->Bool {
//        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
//    }
// }
