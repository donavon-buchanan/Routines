//
//  ViewControllerExtension.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/19/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import UIKit
import UserNotifications

extension UIViewController {
    // MARK: - Appearance

    func setAppearance(forSegment segment: Int) {
        // Swtiches
        let switchAppearance = UISwitch.appearance()
        switchAppearance.onTintColor = UIColor(segment: segment)

        // Navigation
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.tintColor = UIColor(segment: Options.getSelectedIndex())
    }

    func debug(file: String = #file, line: Int = #line, function: String = #function) -> String {
        "\(file):\(line) : \(function)"
    }

    // MARK: - Notifications

//    func checkNotificationPermission() {
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { notificationsOn, _ in
//            if !notificationsOn {
//                self.notificationPermissionsAlert()
//            }
//        }
//    }

    // MARK: - Segues

//    func segueToRoutinesPlusViewController() {
//        guard (AppDelegate.productInfo?.retrievedProducts.count ?? 0) > 0 else { showFailAlert(); return }
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let RoutinesPlusViewController = storyBoard.instantiateViewController(withIdentifier: "RoutinesPlusView") as! RoutinesPlusViewController
//        navigationController?.pushViewController(RoutinesPlusViewController, animated: true)
//    }

    // MARK: - Settings Alerts

    func notificationPermissionsAlert() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: AppStrings.notificationPermissionsAlertTitle,
                message: AppStrings.notificationPermissionsMessage, preferredStyle: .alert
            )
            let notNowAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
            let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
                // go to app's Settings
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            alertController.addAction(settingsAction)
            alertController.addAction(notNowAction)
            self.showAlert(alert: alertController)
        }
    }

    // MARK: - IAP Alerts

//    func alertWithTitle(title: String, message: String) -> UIAlertController {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//        return alertController
//    }
//
//    func alertWithTitleAndDismiss(title: String, message: String) -> UIAlertController {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
//            self.navigationController?.popViewController(animated: true)
//        }))
//        return alertController
//    }
//
    func showAlert(alert: UIAlertController) {
        DispatchQueue.main.async {
            guard self.presentedViewController != nil else {
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }

//
//
//    func alertForProductRetrievalInfo(result: RetrieveResults) -> UIAlertController {
//        if let product = result.retrievedProducts.first {
//            let priceString = product.localizedPrice!
//            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
//        } else if let invalidProductID = result.invalidProductIDs.first {
//            return alertWithTitle(title: AppStrings.productInfoFail, message: "Invalid Product ID: \(invalidProductID). Please contact support.")
//        } else {
//            let error = result.error?.localizedDescription ?? AppStrings.unknownError
//            return alertWithTitle(title: "Error", message: error)
//        }
//    }
//
//    func alertForPurchaseResult(result: PurchaseResult) -> UIAlertController {
//        switch result {
//        case let .success(product):
//            debugPrint("Purchase Sucessful: \(product.productId)")
//            return alertWithTitleAndDismiss(title: AppStrings.purchaseCompelte, message: AppStrings.thank)
//        case let .error(error):
//            debugPrint("Purchase Failed: \(error)")
//            switch error.code {
//            case .cloudServiceNetworkConnectionFailed:
//                if (error as NSError).domain == SKErrorDomain {
//                    return alertWithTitle(title: AppStrings.purchaseFailed, message: AppStrings.checkConnection)
//                } else {
//                    return alertWithTitle(title: AppStrings.purchaseFailed, message: AppStrings.checkConnection)
//                }
//            case .invalidOfferIdentifier:
//                return alertWithTitle(title: AppStrings.purchaseFailed, message: AppStrings.invalidID)
//            case .paymentCancelled:
//                return alertWithTitle(title: AppStrings.purchaseIncomplete, message: AppStrings.paymentCanceled)
//            case .paymentNotAllowed:
//                return alertWithTitle(title: AppStrings.purchaseFailed, message: AppStrings.paymentNotAllowed)
//            case .privacyAcknowledgementRequired:
//                return alertWithTitle(title: AppStrings.purchaseIncomplete, message: AppStrings.privacyAcknowledgementRequired)
//            default:
//                return alertWithTitle(title: AppStrings.purchaseFailed, message: AppStrings.unknownError)
//            }
//        }
//    }
//
//    func alertForRestorePurchases(result: RestoreResults) -> UIAlertController {
//        if result.restoreFailedPurchases.count > 0 {
//            debugPrint(result.restoreFailedPurchases)
//            return alertWithTitle(title: AppStrings.restoreFailed, message: AppStrings.restoreFailedMessage)
//        } else if result.restoredPurchases.count > 0 {
//            return alertWithTitleAndDismiss(title: AppStrings.purchaseRestored, message: AppStrings.thank)
//        } else {
//            return alertWithTitle(title: AppStrings.restoreFailed, message: AppStrings.noPurchase)
//        }
//    }
//
//    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
//        switch result {
//        case .success:
//            return alertWithTitle(title: AppStrings.success, message: AppStrings.receiptVerified)
//        case let .error(error):
//            switch error {
//            case .noReceiptData:
//                return alertWithTitle(title: AppStrings.verificationFailed, message: AppStrings.noReceiptFound)
//            default:
//                return alertWithTitle(title: AppStrings.verificationFailed, message: AppStrings.receiptInvalidMessage)
//            }
//        }
//    }
//
//    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        switch result {
//        case let .expired(expiredSubInfo):
//            return alertWithTitle(title: AppStrings.subExpired, message: AppStrings.subExpiryDate + dateFormatter.string(from: expiredSubInfo.expiryDate))
//        case .notPurchased:
//            return alertWithTitle(title: AppStrings.notPurchased, message: AppStrings.noPurchase)
//        case let .purchased(subInfo):
//            return alertWithTitle(title: AppStrings.subActive, message: AppStrings.subActiveUntil + dateFormatter.string(from: subInfo.expiryDate))
//        }
//    }
//
//    func alertForVerifyPurchase(result: VerifyPurchaseResult) -> UIAlertController {
//        switch result {
//        case .purchased:
//            return alertWithTitle(title: AppStrings.purchased, message: AppStrings.purchasedMessage)
//        case .notPurchased:
//            return alertWithTitle(title: AppStrings.notPurchased, message: AppStrings.notPurchasedMessage)
//        }
//    }
//
//    func alertForRefreshReceipt(result: FetchReceiptResult) -> UIAlertController {
//        switch result {
//        case .success:
//            return alertWithTitle(title: AppStrings.fetchedReceipt, message: AppStrings.fetchedReceiptMessage)
//        case let .error(error):
//            return alertWithTitle(title: AppStrings.receiptFailed, message: AppStrings.receiptFailedMessage + "\(error)")
//        }
//    }
}
