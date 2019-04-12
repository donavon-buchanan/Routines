//
//  UITableViewCellExtension.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/12/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.mask = maskLayer
    }
}
