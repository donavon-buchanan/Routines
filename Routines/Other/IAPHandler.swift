////
////  IAPHandler.swift
////  Routines
////
////  Created by Donavon Buchanan on 4/19/19.
////  Copyright © 2019 Donavon Buchanan. All rights reserved.
////
//
// import StoreKit
// import SwiftyStoreKit
// import UIKit
//
// extension UIViewController {
//    #if targetEnvironment(simulator) || DEBUG
//        var sharedSecret: String {
//            ""
//        }
//
//    #else
//        var sharedSecret: String {
//            AppSecrets.sharedSecret
//        }
//    #endif
//
//    func getInfo(purchase: RegisteredPurchase) {
//        SwiftyStoreKit.retrieveProductsInfo([purchase.rawValue]) { result in
//            self.showAlert(alert: self.alertForProductRetrievalInfo(result: result))
//        }
//    }
//
//    func getAllProductInfo(productIDs: Set<String>) {
//        SwiftyStoreKit.retrieveProductsInfo(productIDs) { results in
//            AppDelegate.productInfo = results
//        }
//    }
//
//    func purchase(purchase: RegisteredPurchase) {
//        SwiftyStoreKit.purchaseProduct(purchase.rawValue) { result in
//            switch result {
//            case let .success(product):
//                RoutinesPlus.setPurchasedProduct(productID: product.productId)
//                RoutinesPlus.setPurchasedStatus(status: true)
//                if product.needsFinishTransaction {
//                    SwiftyStoreKit.finishTransaction(product.transaction)
//                }
//                self.setExpiryDateFromSubscription(productId: product.productId)
//            default:
//                self.showAlert(alert: self.alertForPurchaseResult(result: result))
//            }
//        }
//    }
//
//    func restorePurchase() {
//        SwiftyStoreKit.restorePurchases(atomically: true, applicationUsername: "") { result in
//            var productId = String()
//            result.restoredPurchases.forEach { product in
//                if product.needsFinishTransaction {
//                    SwiftyStoreKit.finishTransaction(product.transaction)
//                }
//
//                if product.productId == RegisteredPurchase.lifetime.rawValue {
//                    productId = product.productId
//                } else if productId != RegisteredPurchase.lifetime.rawValue {
//                    productId = product.productId
//                    self.setExpiryDateFromSubscription(productId: productId)
//                }
//            }
//            debugPrint("Restored purchase with ID: \(productId)")
//            RoutinesPlus.setPurchasedProduct(productID: productId)
//            if !productId.isEmpty {
//                RoutinesPlus.setPurchasedStatus(status: true)
//            }
//            self.showAlert(alert: self.alertForRestorePurchases(result: result))
//        }
//    }
//
//    func verifyReceipt() {
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
//        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//            // self.showAlert(alert: self.alertForVerifyReceipt(result: result))
//
//            if case let .error(error) = result {
//                if case .noReceiptData = error {
//                    debugPrint("No receipt data. Will attempt to refresh.")
//                    self.refreshReceipt()
//                } else {
//                    debugPrint("Receipt is invalid. Attempting to verify purchase with Apple.")
//                    self.verifyPurchase(product: RegisteredPurchase(rawValue: RoutinesPlus.getPurchasedProduct())!)
//                }
//            } else {
//                debugPrint("Successfully verified receipt.")
//            }
//        }
//    }
//
//    func verifyPurchase(product: RegisteredPurchase) {
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
//        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//            switch result {
//            case .success:
//                debugPrint("Verify purchase result: Success. \(product.rawValue) is valid")
//                RoutinesPlus.setPurchasedProduct(productID: product.rawValue)
//                RoutinesPlus.setPurchasedStatus(status: true)
//                self.setExpiryDateFromSubscription(productId: product.rawValue)
//            case let .error(error):
//                debugPrint("Verify purchase result: Error. No valid purchase active.")
//                RoutinesPlus.setPurchasedProduct(productID: "")
//                RoutinesPlus.setPurchasedStatus(status: false)
//                RoutinesPlus.setCloudSync(toggle: false)
//                Options.setAutomaticDarkModeStatus(false)
//                AppDelegate.syncEngine = nil
//                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
//                if case .noReceiptData = error {
//                    self.refreshReceipt()
//                }
//            }
//        }
//    }
//
//    func setExpiryDateFromSubscription(productId: String) {
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
//        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//            switch result {
//            case let .success(receipt):
//                // Verify the purchase of a Subscription
//                let purchaseResult = SwiftyStoreKit.verifySubscription(
//                    ofType: .autoRenewable, // or .nonRenewing (see below)
//                    productId: productId,
//                    inReceipt: receipt
//                )
//
//                switch purchaseResult {
//                case let .purchased(expiryDate, items):
//                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
//                    RoutinesPlus.setExpiryDate(date: expiryDate)
//                case let .expired(expiryDate, items):
//                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
//                case .notPurchased:
//                    print("The user has never purchased \(productId)")
//                }
//
//            case let .error(error):
//                print("Receipt verification failed: \(error)")
//            }
//        }
//    }
//
//    func refreshReceipt() {
//        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
//            switch result {
//            case .error:
//                debugPrint("Error refreshing receipt. Attempting to verify purchase with Apple.")
//                self.verifyPurchase(product: RegisteredPurchase(rawValue: RoutinesPlus.getPurchasedProduct())!)
//            case .success:
//                debugPrint("Sucessfully refreshed receipt.")
//                self.verifyReceipt()
//            }
//        }
//    }
// }
