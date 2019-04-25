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

    func showFailAlert() {
        let alertController = UIAlertController(title: "Connection Failure", message: "Failed to fetch purchase options from the App Store. Please check your internet conenction and try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        getAllProductInfo(productIDs: [RegisteredPurchase.lifetime.rawValue, RegisteredPurchase.monthly.rawValue, RegisteredPurchase.yearly.rawValue])
    }

    func alertForProductRetrievalInfo(result: RetrieveResults) -> UIAlertController {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductID = result.invalidProductIDs.first {
            return alertWithTitle(title: Messages.productInfoFail, message: "Invalid Product ID: \(invalidProductID). Please contact support.")
        } else {
            let error = result.error?.localizedDescription ?? Messages.unknownError
            return alertWithTitle(title: "Error", message: error)
        }
    }

    func alertForPurchaseResult(result: PurchaseResult) -> UIAlertController {
        switch result {
        case let .success(product):
            #if DEBUG
                print("Purchase Sucessful: \(product.productId)")
            #endif
            return alertWithTitle(title: Messages.purchaseCompelte, message: Messages.thank)
        case let .error(error):
            #if DEBUG
                print("Purchase Failed: \(error)")
            #endif
            switch error.code {
            case .cloudServiceNetworkConnectionFailed:
                if (error as NSError).domain == SKErrorDomain {
                    return alertWithTitle(title: Messages.purchaseFailed, message: Messages.checkConnection)
                } else {
                    return alertWithTitle(title: Messages.purchaseFailed, message: Messages.checkConnection)
                }
            case .invalidOfferIdentifier:
                return alertWithTitle(title: Messages.purchaseFailed, message: Messages.invalidID)
            case .paymentCancelled:
                return alertWithTitle(title: Messages.purchaseIncomplete, message: Messages.paymentCanceled)
            case .paymentNotAllowed:
                return alertWithTitle(title: Messages.purchaseFailed, message: Messages.paymentNotAllowed)
            case .privacyAcknowledgementRequired:
                return alertWithTitle(title: Messages.purchaseIncomplete, message: Messages.privacyAcknowledgementRequired)
            default:
                return alertWithTitle(title: Messages.purchaseFailed, message: Messages.unknownError)
            }
        }
    }

    func alertForRestorePurchases(result: RestoreResults) -> UIAlertController {
        if result.restoreFailedPurchases.count > 0 {
            #if DEBUG
                print(result.restoreFailedPurchases)
            #endif
            return alertWithTitle(title: Messages.restoreFailed, message: Messages.restoreFailedMessage)
        } else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: Messages.purchaseRestored, message: Messages.thank)
        } else {
            return alertWithTitle(title: Messages.restoreFailed, message: Messages.noPurchase)
        }
    }

    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
        switch result {
        case .success:
            return alertWithTitle(title: Messages.success, message: Messages.receiptVerified)
        case let .error(error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: Messages.verificationFailed, message: Messages.noReceiptFound)
            default:
                return alertWithTitle(title: Messages.verificationFailed, message: Messages.verificationUnknown)
            }
        }
    }

    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        switch result {
        case let .expired(expiredSubInfo):
            return alertWithTitle(title: Messages.subExpired, message: Messages.subExpiryDate + dateFormatter.string(from: expiredSubInfo.expiryDate))
        case .notPurchased:
            return alertWithTitle(title: Messages.notPurchased, message: Messages.noPurchase)
        case let .purchased(subInfo):
            return alertWithTitle(title: Messages.subActive, message: Messages.subActiveUntil + dateFormatter.string(from: subInfo.expiryDate))
        }
    }

    func alertForVerifyPurchase(result: VerifyPurchaseResult) -> UIAlertController {
        switch result {
        case .purchased:
            return alertWithTitle(title: Messages.purchased, message: Messages.purchasedMessage)
        case .notPurchased:
            return alertWithTitle(title: Messages.notPurchased, message: Messages.notPurchasedMessage)
        }
    }

    func alertForRefreshReceipt(result: FetchReceiptResult) -> UIAlertController {
        switch result {
        case .success:
            return alertWithTitle(title: Messages.fetchedReceipt, message: Messages.fetchedReceiptMessage)
        case let .error(error):
            return alertWithTitle(title: Messages.receiptFailed, message: Messages.receiptFailedMessage + "\(error)")
        }
    }
}
