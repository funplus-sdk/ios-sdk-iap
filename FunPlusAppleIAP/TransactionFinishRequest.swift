//
//  TransactionFinishRequest.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/30/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import StoreKit

open class TransactionFinishRequest {
    
    open func complete(_ handler: @escaping (_ transactions: [SKPaymentTransaction]) -> Void) {
        PaymentQueueProxy.sharedInstance.foreceFinishPendingTransactions(handler)
    }
}
