//
//  Messages.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/19/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation

enum Messages: String {
    case unknownError = "Unkown Error. Please contact support"
    case checkConnection = "Please check your internet connection and try again."
    case purchaseFailed = "Purchase Failed"
    case purchaseIncomplete = "Purchase Incomplete"
    case purchaseCompelte = "Purchase Complete"
    case thank = "Thank you for your support!"
    case productInfoFail = "Could not retrieve product info."
    case invalidID = "Invalid Product ID. Please contact support."
    case paymentCanceled = "Payment was canceled."
    case paymentNotAllowed = "Uh oh. Looks like you're not allowed to make payments on this device."
    case privacyAcknowledgementRequired = "Apple requires that you agree to their updated Privacy Policy before making this purchase. Please check your account."
    case restoreFailed = "Restore Failed"
    case restoreFailedMessage = "Failed to restore purchases. If you believe this is an error, please contact support."
    case purchaseRestored = "Purchase Restored"
    case noPurchase = "No purchases were found."
    case success = "Success"
    case receiptVerified = "Receipt verified remotely."
    case verificationFailed = "Receipt Verification Failed"
    case noReceiptFound = "No receipt data was found. We'll try to fetch a new one. Try again."
    case verificationUnknown = "Receipt verification failed with an unknown error. Please try again. If this error continues, contact support."
    case subActive = "Subscription Active"
    case subActiveUntil = "Your subscription will renew on "
    case subExpired = "Subscription Expired"
    case subExpiryDate = "Your subscription expired on "
    case purchased = "Product Purchased"
    case purchasedMessage = "This purchase does not expire."
    case notPurchased = "Product Not Purchased"
    case notPurchasedMessage = "You have not yet purchased this product"
    case fetchedReceipt = "Receipt Fetched"
    case fetchedReceiptMessage = "Successfully fetched new receipt."
    case receiptFailed = "Refresh Failed"
    case receiptFailedMessage = "Failed to refresh receipt. Please contact support. Error: "
}
