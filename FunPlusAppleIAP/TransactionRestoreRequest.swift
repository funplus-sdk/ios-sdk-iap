//
//  TransactionRestoreRequest.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/27/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import StoreKit

public enum TransactionRestoreError : Error {
    case restoreError(NSError)
}

public enum TransactionRestoreResult {
    case success(transactions: [SKPaymentTransaction])
    case failed(error: TransactionRestoreError)
}

open class TransactionRestoreRequest {
    
    open func complete(_ handler: @escaping (TransactionRestoreResult) -> Void) {
        PaymentQueueProxy.sharedInstance.restoreCompletedTransactions(handler)
    }
}
