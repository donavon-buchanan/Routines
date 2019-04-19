//
//  ViewControllerExtension.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/19/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import StoreKit
import SwiftyStoreKit
import UIKit

extension UIViewController {
    func alertWithTitle(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertController
    }

    func showAlert(alert: UIAlertController) {
        guard let _ = self.presentedViewController else {
            present(alert, animated: true, completion: nil)
            return
        }
    }

    func alertForProductRetrievalInfo(result: RetrieveResults) -> UIAlertController {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductID = result.invalidProductIDs.first {
            return alertWithTitle(title: Messages.productInfoFail.rawValue, message: "Invalid Product ID: \(invalidProductID). Please contact support.")
        } else {
            let error = result.error?.localizedDescription ?? Messages.unknownError.rawValue
            return alertWithTitle(title: "Error", message: error)
        }
    }

    func alertForPurchaseResult(result: PurchaseResult) -> UIAlertController {
        switch result {
        case let .success(product):
            #if DEBUG
                print("Purchase Sucessful: \(product.productId)")
            #endif
            return alertWithTitle(title: Messages.purchaseCompelte.rawValue, message: Messages.thank.rawValue)
        case let .error(error):
            #if DEBUG
                print("Purchase Failed: \(error)")
            #endif
            switch error.code {
            case .cloudServiceNetworkConnectionFailed:
                if (error as NSError).domain == SKErrorDomain {
                    return alertWithTitle(title: Messages.purchaseFailed.rawValue, message: Messages.checkConnection.rawValue)
                } else {
                    return alertWithTitle(title: Messages.purchaseFailed.rawValue, message: Messages.checkConnection.rawValue)
                }
            case .invalidOfferIdentifier:
                return alertWithTitle(title: Messages.purchaseFailed.rawValue, message: Messages.invalidID.rawValue)
            default:
                return alertWithTitle(title: Messages.purchaseFailed.rawValue, message: Messages.unknownError.rawValue)
            }
        }
    }
}
