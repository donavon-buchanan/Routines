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
            case .paymentCancelled:
                return alertWithTitle(title: Messages.purchaseIncomplete.rawValue, message: Messages.paymentCanceled.rawValue)
            case .paymentNotAllowed:
                return alertWithTitle(title: Messages.purchaseFailed.rawValue, message: Messages.paymentNotAllowed.rawValue)
            case .privacyAcknowledgementRequired:
                return alertWithTitle(title: Messages.purchaseIncomplete.rawValue, message: Messages.privacyAcknowledgementRequired.rawValue)
            default:
                return alertWithTitle(title: Messages.purchaseFailed.rawValue, message: Messages.unknownError.rawValue)
            }
        }
    }

    func alertForRestorePurchases(result: RestoreResults) -> UIAlertController {
        if result.restoreFailedPurchases.count > 0 {
            #if DEBUG
                print(result.restoreFailedPurchases)
            #endif
            return alertWithTitle(title: Messages.restoreFailed.rawValue, message: Messages.restoreFailedMessage.rawValue)
        } else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: Messages.purchaseRestored.rawValue, message: Messages.thank.rawValue)
        } else {
            return alertWithTitle(title: Messages.restoreFailed.rawValue, message: Messages.noPurchase.rawValue)
        }
    }

    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
        switch result {
        case .success:
            return alertWithTitle(title: Messages.success.rawValue, message: Messages.receiptVerified.rawValue)
        case let .error(error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: Messages.verificationFailed.rawValue, message: Messages.noReceiptFound.rawValue)
            default:
                return alertWithTitle(title: Messages.verificationFailed.rawValue, message: Messages.verificationUnknown.rawValue)
            }
        }
    }

    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        switch result {
        case let .expired(expiredSubInfo):
            return alertWithTitle(title: Messages.subExpired.rawValue, message: Messages.subExpiryDate.rawValue + dateFormatter.string(from: expiredSubInfo.expiryDate))
        case .notPurchased:
            return alertWithTitle(title: Messages.notPurchased.rawValue, message: Messages.noPurchase.rawValue)
        case let .purchased(subInfo):
            return alertWithTitle(title: Messages.subActive.rawValue, message: Messages.subActiveUntil.rawValue + dateFormatter.string(from: subInfo.expiryDate))
        }
    }

    func alertForVerifyPurchase(result: VerifyPurchaseResult) -> UIAlertController {
        switch result {
        case .purchased:
            return alertWithTitle(title: Messages.purchased.rawValue, message: Messages.purchasedMessage.rawValue)
        case .notPurchased:
            return alertWithTitle(title: Messages.notPurchased.rawValue, message: Messages.notPurchasedMessage.rawValue)
        }
    }

    func alertForRefreshReceipt(result: FetchReceiptResult) -> UIAlertController {
        switch result {
        case .success:
            return alertWithTitle(title: Messages.fetchedReceipt.rawValue, message: Messages.fetchedReceiptMessage.rawValue)
        case let .error(error):
            return alertWithTitle(title: Messages.receiptFailed.rawValue, message: Messages.receiptFailedMessage.rawValue + "\(error)")
        }
    }
}
