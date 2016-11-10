//
//  PaymentQueueProxy.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/27/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - PaymentQueueProxy

/**
    The `PaymentQueueProxy` class represents the transaction observer for StoreKit.
 
    Three kinds of request can be present:
 
    1. A force finishing request for all pending transactions; Pending transactions
       exist when user starts a purchase and kills the app and then restart the app.
    2. A purchasing request.
    3. A restroing request for all completed transactions of non-consumable products.
 */
class PaymentQueueProxy : NSObject, SKPaymentTransactionObserver {
    
    /// The shared instance.
    static let sharedInstance: PaymentQueueProxy = {
        return PaymentQueueProxy()
    }()
    
    /// The payment queue.
    var paymentQueue: SKPaymentQueue {
        return SKPaymentQueue.default()
    }
    
    /// The purchase request delegates.
    var purchaseRequestDelegates = [String: ProductPurchaseRequestDelegate]()
    
    /// The restored transactions.
    var restoredTransactions = [SKPaymentTransaction]()
    
    /// The completion handler for a restore process.
    var restoreHandler: ((TransactionRestoreResult) -> Void)?
    
    /// The pending transactions.
    var pendingTransactions = [SKPaymentTransaction]()
    
    /// The completion handler for a force finish process.
    var forceFinishHandler: ((_ transactions: [SKPaymentTransaction]) -> Void)?
    
    override init() {
        super.init()
        paymentQueue.add(self)
    }
    
    deinit {
        paymentQueue.remove(self)
    }
    
    /**
        Purchase a given product.
     
        - parameter product:                    The product to purchase.
        - parameter quantity:                   The uantity of product ot purchase.
        - parameter applicationUsername:        The application username.
        - parameter purchaseRequestDelegate:    The delegate for this request.
     */
    func purchaseProduct(
        product: SKProduct,
        quantity: Int,
        applicationUsername: String,
        purchaseRequestDelegate: ProductPurchaseRequestDelegate)
    {
        let delegateId = "\(product.hash)"
        purchaseRequestDelegates["\(delegateId)"] = purchaseRequestDelegate
        
        let payment = SKMutablePayment(product: product)
        payment.quantity = quantity
        payment.applicationUsername = "\(delegateId):\(applicationUsername)"
        
        DispatchQueue.global(qos: .default).async {
            self.paymentQueue.add(payment)
        }
    }
    
    /**
        Restore completed transactions.
     
        - parameter handler:    The handler for this request.
     */
    func restoreCompletedTransactions(_ handler: @escaping (TransactionRestoreResult) -> Void) {
        restoreHandler = handler
        
        DispatchQueue.global(qos: .default).async {
            self.paymentQueue.restoreCompletedTransactions()
        }
    }
    
    /**
        Finish a given transaction.
     
        - parameter transaction:    The transaction to finish.
     */
    func finishTransaction(_ transaction: SKPaymentTransaction) {
        paymentQueue.finishTransaction(transaction)
    }
    
    /**
        Force finish pending transactions.
     
        - parameter handler:    The handler for this request.
     */
    func foreceFinishPendingTransactions(_ handler: @escaping ([SKPaymentTransaction]) -> Void) {
        self.forceFinishHandler = handler
    }
    
    /**
        When transactions in the payment queue get updated. Transaction needs to be
        finished when it is in Purchased/Restored/Failed state.
     
        - parameter queue:          The payment queue.
        - parameter transactions:   The updated transactions.
     */
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let delegateId = transaction.payment.applicationUsername?.components(separatedBy: ":").first
            let transactionState = transaction.transactionState
            
            switch transactionState {
            case .purchased:
                //==============================================
                //  1. IF:   a normal purchase process?
                //  3. ELSE: put it to pending transactions.
                //==============================================
                if let delegateId = delegateId, let delegate = purchaseRequestDelegates[delegateId] {
                    delegate.completionHandler?(.success(transaction: transaction))
                    purchaseRequestDelegates[delegateId] = nil
                } else {
                    pendingTransactions.append(transaction)
                }
                
                paymentQueue.finishTransaction(transaction)
                
            case .restored:
                //==============================================
                //  1. IF:   a normal purchase process?
                //  2. ELIF: a restore process?
                //  3. ELSE: put it to pending transactions.
                //==============================================
                if let delegateId = delegateId, let delegate = purchaseRequestDelegates[delegateId] {
                    delegate.completionHandler?(.success(transaction: transaction))
                    purchaseRequestDelegates[delegateId] = nil
                } else if restoreHandler != nil {
                    restoredTransactions.append(transaction)
                } else {
                    pendingTransactions.append(transaction)
                }

                paymentQueue.finishTransaction(transaction)
                
            case .failed:
                //==============================================
                //  1. IF:   a normal purchase process?
                //  2. ELIF: a restore process?
                //  3. ELSE: ignore this transaction.
                //==============================================
                if let delegateId = delegateId, let delegate = purchaseRequestDelegates[delegateId] {
                    let message = "Transaction failed for product ID: \(transaction.payment.productIdentifier)"
                    let altError = NSError(domain: SKErrorDomain, code: 0, userInfo: [ NSLocalizedDescriptionKey: message ])
                    delegate.completionHandler?(.failed(error: .purchaseError(transaction.error as NSError? ?? altError)))
                    purchaseRequestDelegates[delegateId] = nil
                } else if restoreHandler != nil {
                    // TODO
                }
                
                paymentQueue.finishTransaction(transaction)
                
            case .purchasing:
                if let delegateId = delegateId, let delegate = purchaseRequestDelegates[delegateId] {
                    delegate.progressHandler?()
                }
                break
                
            case .deferred:
                if let delegateId = delegateId, let delegate = purchaseRequestDelegates[delegateId] {
                    delegate.progressHandler?()
                }
            }
        }
        
        if let handler = forceFinishHandler {
            handler(pendingTransactions)
            self.pendingTransactions.removeAll()
            self.forceFinishHandler = nil
        }
    }
    
    /**
        When transactions in the payment queue get removed.
     
        - parameter queue:          The payment queue.
        - parameter transactions:   The removed transactions.
     */
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            purchaseRequestDelegates[transaction.payment.productIdentifier] = nil
        }
    }
    
    /**
        When fails to restore completed transactions.
     
        - parameter queue:          The payment queue.
        - parameter error:          The error that causes the failure.
     */
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let handler = restoreHandler {
            handler(.failed(error: .restoreError(error as NSError)))
            self.restoreHandler = nil
            self.restoredTransactions.removeAll()
        }
    }
    
    /**
        When transactions restored. This method will be called after all transactions have been
        restored, includes the case of no transactions.
     
        - parameter queue:          The payment queue.
     */
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if let handler = restoreHandler {
            handler(.success(transactions: restoredTransactions))
            self.restoreHandler = nil
            self.restoredTransactions.removeAll()
        }
    }
    
    /**
        When downloads updated.
     
        - parameter queue:          The payment queue.
        - parameter downloads:      The updated downloads.
     */
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        
    }
}
