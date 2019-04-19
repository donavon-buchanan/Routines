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

extension OptionsTableViewController {
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
            self.productInfo = results
        }
    }

    func purchase(purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(purchase.rawValue) { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            switch result {
            case let .success(product):
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                self.showAlert(alert: self.alertForPurchaseResult(result: result))
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
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            self.showAlert(alert: self.alertForRestorePurchases(result: result))
        }
    }

    func verifyReceipt() {
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))

            if case let .error(error) = result {
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
    }

    func verifyPurchase(product: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            NetworkActivityIndicatorManager.networkOperationEnded()
            switch result {
            case let .success(receipt):
                switch product {
                case .lifetime:
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: product.rawValue, inReceipt: receipt)
                    self.showAlert(alert: self.alertForVerifyPurchase(result: purchaseResult))
                default:
                    // let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: product.rawValue, inReceipt: receipt)
                    let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: product.rawValue, inReceipt: receipt, validUntil: Date())
                    self.showAlert(alert: self.alertForVerifySubscription(result: purchaseResult))
                }

            case let .error(error):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
    }

    func refreshReceipt() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            self.showAlert(alert: self.alertForRefreshReceipt(result: result))
        }
    }
}
