//
//  Notifications.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/30/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation

/**
    Notification names.
 */
struct Notifications {
    /// Notification posted when product query request succeeds.
    static let ProductQuerySuccess              = "com.funplus.sdk.appleiap.ProductQuerySuccess"
    
    /// Notification posted when product query request fails.
    static let ProductQueryFailed               = "com.funplus.sdk.appleiap.ProductQueryFailed"
    
    /// Notification posted when product purchase request succeeds.
    static let ProductPurchaseSuccess           = "com.funplus.sdk.appleiap.ProductPurchaseSuccess"
    
    /// Notification posted when product purchase request fails.
    static let ProductPurchaseFailed            = "com.funplus.sdk.appleiap.ProductPurchaseFails"
    
    /// Notification posted when transaction restore request succeeds.
    static let TransactionRestoreSuccess        = "com.funplus.sdk.appleiap.TransactionRestoreSuccess"
    
    /// Notification posted when transaction restore request fails.
    static let TransactionRestoreFailed         = "com.funplus.sdk.appleiap.TransactionRestoreFailed"
    
    /// Notification posted when transaction force finish request completes.
    static let TransactionForceFinishComplete   = "com.funplus.sdk.appleiap.TransactionForceFinishComplete"
    
    /// Notification posted when receipt refresh succeeds.
    static let ReceiptRefreshSuccess            = "com.funplus.sdk.appleiap.ReceiptRefreshSuccess"
    
    /// Notification posted when receipt refresh fails.
    static let ReceiptRefreshFailed             = "com.funplus.sdk.appleiap.ReceiptRefreshFailed"
}