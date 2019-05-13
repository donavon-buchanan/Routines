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
                RoutinesPlus.setPurchasedProduct(productID: product.productId)
                RoutinesPlus.setPurchasedStatus(status: true)
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                self.setExpiryDateFromSubscription(productId: product.productId)
            default:
                self.showAlert(alert: self.alertForPurchaseResult(result: result))
            }
        }
    }

    func restorePurchase() {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true, applicationUsername: "") { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            var productId = String()
            result.restoredPurchases.forEach { product in
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }

                if product.productId == RegisteredPurchase.lifetime.rawValue {
                    productId = product.productId
                } else if productId != RegisteredPurchase.lifetime.rawValue {
                    productId = product.productId
                    self.setExpiryDateFromSubscription(productId: productId)
                }
            }
            printDebug("Restored purchase with ID: \(productId)")
            RoutinesPlus.setPurchasedProduct(productID: productId)
            if !productId.isEmpty {
                RoutinesPlus.setPurchasedStatus(status: true)
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
                    printDebug("No receipt data. Will attempt to refresh.")
                    self.refreshReceipt()
                } else {
                    printDebug("Receipt is invalid. Attempting to verify purchase with Apple.")
                    self.verifyPurchase(product: RegisteredPurchase(rawValue: RoutinesPlus.getPurchasedProduct())!)
                }
            } else {
                printDebug("Successfully verified receipt.")
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
                printDebug("Verify purchase result: Success. \(product.rawValue) is valid")
                RoutinesPlus.setPurchasedProduct(productID: product.rawValue)
                RoutinesPlus.setPurchasedStatus(status: true)
                self.setExpiryDateFromSubscription(productId: product.rawValue)
            case let .error(error):
                printDebug("Verify purchase result: Error. No valid purchase active.")
                RoutinesPlus.setPurchasedProduct(productID: "")
                RoutinesPlus.setPurchasedStatus(status: false)
                RoutinesPlus.setCloudSync(toggle: false)
                Options.setAutomaticDarkModeStatus(false)
                AppDelegate.syncEngine = nil
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
    }

    func setExpiryDateFromSubscription(productId: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case let .success(receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt
                )

                switch purchaseResult {
                case let .purchased(expiryDate, items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    RoutinesPlus.setExpiryDate(date: expiryDate)
                case let .expired(expiryDate, items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }

            case let .error(error):
                print("Receipt verification failed: \(error)")
            }
        }
    }

    func refreshReceipt() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .error:
                printDebug("Error refreshing receipt. Attempting to verify purchase with Apple.")
                self.verifyPurchase(product: RegisteredPurchase(rawValue: RoutinesPlus.getPurchasedProduct())!)
            case .success:
                printDebug("Sucessfully refreshed receipt.")
                self.verifyReceipt()
            }
        }
    }
}
