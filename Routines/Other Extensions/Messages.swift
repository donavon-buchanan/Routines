//
//  Messages.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/19/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation

struct Messages {
    static let unknownError = "Unkown Error. Please contact support"
    static let checkConnection = "Please check your internet connection and try again."
    static let purchaseFailed = "Purchase Failed"
    static let purchaseIncomplete = "Purchase Incomplete"
    static let purchaseCompelte = "Purchase Complete"
    static let thank = "Thank you for your support!"
    static let productInfoFail = "Could not retrieve product info."
    static let invalidID = "Invalid Product ID. Please contact support."
    static let paymentCanceled = "Payment was canceled."
    static let paymentNotAllowed = "Uh oh. Looks like you're not allowed to make payments on this device."
    static let privacyAcknowledgementRequired = "Apple requires that you agree to their updated Privacy Policy before making this purchase. Please check your account."
    static let restoreFailed = "Restore Failed"
    static let restoreFailedMessage = "Failed to restore purchases. If you believe this is an error, please contact support."
    static let purchaseRestored = "Purchase Restored"
    static let noPurchase = "No purchases were found."
    static let success = "Success"
    static let receiptVerified = "Receipt verified remotely."
    static let verificationFailed = "Receipt Verification Failed"
    static let noReceiptFound = "No receipt data was found. We'll try to fetch a new one. Try again."
    static let verificationUnknown = "Receipt verification failed with an unknown error. Please try again. If this error continues, contact support."
    static let receiptInvalidMessage = "Looks like your subscription has expired. Certain features may be disabled."
    static let subActive = "Subscription Active"
    static let subActiveUntil = "Your subscription will renew on "
    static let subExpired = "Subscription Expired"
    static let subExpiryDate = "Your subscription expired on "
    static let purchased = "Product Purchased"
    static let purchasedMessage = "This purchase does not expire."
    static let notPurchased = "Product Not Purchased"
    static let notPurchasedMessage = "You have not yet purchased this product"
    static let fetchedReceipt = "Receipt Fetched"
    static let fetchedReceiptMessage = "Successfully fetched new receipt."
    static let receiptFailed = "Refresh Failed"
    static let receiptFailedMessage = "Failed to refresh receipt. Please contact support. Error: "
}
