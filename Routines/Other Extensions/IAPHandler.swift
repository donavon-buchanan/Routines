//
//  IAPHandler.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/19/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import StoreKit
import SwiftyStoreKit
import UIKit

extension UIViewController {
    func getInfo(purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            self.showAlert(alert: self.alertForProductRetrievalInfo(result: result))
        }
    }

    func getAllProductInfo(productIDs: Set<String>) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo(productIDs) { results in
            NetworkActivityIndicatorManager.networkOperationEnded()
            AppDelegate.productInfo = results
        }
    }

    func purchase(purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(purchase.rawValue) { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            switch result {
            case let .success(product):
                Options.setPurchasedProduct(productID: product.productId)
                Options.setPurchasedStatus(status: true)
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            // self.showAlert(alert: self.alertForPurchaseResult(result: result))
            default:
                self.showAlert(alert: self.alertForPurchaseResult(result: result))
            }
        }
    }

    func restorePurchase() {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true, applicationUsername: "") { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            result.restoredPurchases.forEach { product in
                #if DEBUG
                    print("Restored purchase with ID: \(product.productId)")
                #endif
                Options.setPurchasedProduct(productID: product.productId)
                Options.setPurchasedStatus(status: true)
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            self.showAlert(alert: self.alertForRestorePurchases(result: result))
        }
    }

    func verifyReceipt() {
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            // self.showAlert(alert: self.alertForVerifyReceipt(result: result))

            if case let .error(error) = result {
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
    }

    func verifyPurchase(product: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            switch result {
            case .success:
                #if DEBUG
                    print("Verify purchase result: Success. \(product.rawValue) is valid")
                #endif
                Options.setPurchasedProduct(productID: product.rawValue)
                Options.setPurchasedStatus(status: true)
            //                switch product {
            //                case .lifetime:
            //                    // let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: product.rawValue, inReceipt: receipt)
            //                   // Options.setPurchaseExpiration(expiryDate: DateComponents(year: 10000).date!)
            //                default:
            //                    let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: product.rawValue, inReceipt: receipt, validUntil: Date())
            //                    // self.showAlert(alert: self.alertForVerifySubscription(result: purchaseResult))
            //                }
            case let .error(error):
                #if DEBUG
                    print("Verify purchase result: Error. No valid purchase active.")
                #endif
                Options.setPurchasedProduct(productID: "")
                Options.setPurchasedStatus(status: false)
                Options.setCloudSync(toggle: false)
                Options.setAutomaticDarkModeStatus(false)
                AppDelegate.syncEngine = nil
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
    }

    func refreshReceipt() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { _ in
            // self.showAlert(alert: self.alertForRefreshReceipt(result: result))
        }
    }
}
