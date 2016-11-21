//
//  FunPlusAppleIAP.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/27/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - FunPlusAppleIAP

/**
    The `FunPlusAppleIAP` class is a proxy between application and apple's StoreKit.
    It provides a smooth way to deal with processes such as purchasing and restoring
    products.
 */
public class FunPlusAppleIAP {
    
    public static let VERSION = "4.0.0-alpha.0"
    
    // MARK: - Query Products
    
    /**
        Query products information with the given array of product identifiers.
     
        - parameter productIdentifiers:     The identifiers of products to query.
        - parameter completion:             The completion handler.
     
        - returns:  A new `ProductQueryRequest` instance.
     */
    public class func queryProducts(_ productIdentifiers: [String], completion: @escaping (ProductQueryResult) -> Void) {
        ProductQueryRequest(productIdentifiers: productIdentifiers).complete(completion)
    }
    
    // MARK: - Purchase Product
    
    /**
        Check purchase permission.
     
        - returns:  `true` if user can make payments. `false` otherwise.
     */
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /**
        Purchase the product specified by the given identifier.
     
        - parameter productIdentifier:      The identifier of product to purchase.
        - parameter quantity:               The quantity of product to purchase.
        - parameter applicationUsername:    The application username.
        - parameter completion:             The completion handler.
     */
    public class func purchaseProduct(
        _ productIdentifier: String,
        quantity: Int = 1,
        applicationUsername: String = "",
        completion: @escaping (ProductPurchaseResult) -> Void)
    {
        ProductPurchaseRequest(
            productIdentifier: productIdentifier,
            quantity: quantity,
            applicationUsername: applicationUsername
        ).complete(completion)
    }
    
    // MARK: - Restore Transactions
    
    /**
        Restore previous transactions.
     
        - parameter completion:             The completion handler.
     */
    public class func restoreCompletedTransactions(_ completion: @escaping (TransactionRestoreResult) -> Void) {
        TransactionRestoreRequest().complete(completion)
    }
    
    // MARK: - Finish Transactions
    
    /**
        Finish the given transaction. A transaction should always be finished no matter whether
        the payment process is successful or not.
     
        - parameter transaction:    The transaction to be finished.
     */
    public class func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /**
        Force finish pending transactions.
     
        - parameter completion:             The completion handler.
     */
    public class func foreceFinishPendingTransactions(_ completion: @escaping (_ transactions: [SKPaymentTransaction]) -> Void) {
        TransactionFinishRequest().complete(completion)
    }
    
    // MARK: - Verify Receipt
    
    public class func verifyReceipt(
        receiptVerifyURL url: ReceiptVerifyURL = .productionURL,
        password: String? = nil,
        completion: @escaping (ReceiptVerifyResult) -> Void)
    {
        ReceiptManager.verify(recepitVerifyURL: url, password: password, completion: completion)
    }
    
    public class func verifyPurchase(
        productIdentifer: String,
        inReceipt receipt: Receipt) -> PurchaseVerifyResult
    {
        return ReceiptManager.verifyPurchase(productIdentifier: productIdentifer, inReceipt: receipt)
    }
    
    // MARK: - Refresh Receipt
    
    public class func refreshReceipt() -> ReceiptRefreshRequest {
        return ReceiptRefreshRequest()
    }
}
