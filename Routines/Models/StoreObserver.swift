//
//  StoreObserver.swift
//  Routines
//
//  Created by Donavon Buchanan on 4/17/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import Foundation
import StoreKit

class StoreObserver: NSObject, SKPaymentTransactionObserver {
    // Initialize the store observer.
    override init() {
        super.init()
        // Other initialization here.
    }

    // MARK: - Handling Transations

    // Observe transaction updates.
    func paymentQueue(_: SKPaymentQueue, updatedTransactions _: [SKPaymentTransaction]) {
        // Handle transaction states here.
    }

    func paymentQueue(_: SKPaymentQueue, removedTransactions _: [SKPaymentTransaction]) {}

    // MARK: - Handling Restored Transactions

    func paymentQueue(_: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError _: Error) {}

    func paymentQueueRestoreCompletedTransactionsFinished(_: SKPaymentQueue) {}

    // MARK: - Handling Purchases

    func paymentQueue(_: SKPaymentQueue, shouldAddStorePayment _: SKPayment, for _: SKProduct) -> Bool {
        return true
    }
}
