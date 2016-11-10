//
//  ReceiptRefreshRequest.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/27/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import StoreKit

public enum ReceiptRefreshResult {
    case success
    case failed(error: NSError)
}

// MARK: - ReceiptRefreshRequest

open class ReceiptRefreshRequest : NSObject, SKRequestDelegate {
    
    // MARK: - Properties
    
    /// The container to cache all the underlying requests.
    static var underlyingRequests = [Int: ReceiptRefreshRequest]()
    
    var receiptProperties: [String: AnyObject]?
    
    /// The underlying request.
    var request: SKReceiptRefreshRequest?
    
    /// The completion handler.
    var completionHandler: ((ReceiptRefreshResult) -> Void)?
    
    init(receiptProperties: [String: AnyObject]? = nil) {
        self.receiptProperties = receiptProperties
        
        super.init()
        ReceiptRefreshRequest.underlyingRequests[self.hash] = self
    }
    
    deinit {
        self.request?.delegate = nil
    }
    
    open func complete(_ handler: @escaping (ReceiptRefreshResult) -> Void) {
        self.completionHandler = handler
        self.request = SKReceiptRefreshRequest(receiptProperties: receiptProperties)
        self.request?.delegate = self
        self.request?.start()
    }

    // MARK: - SKRequestDelegate
    
    open func requestDidFinish(_ request: SKRequest) {
        self.completionHandler?(.success)
        ReceiptRefreshRequest.underlyingRequests[self.hash] = nil
    }
    
    open func request(_ request: SKRequest, didFailWithError error: Error) {
        self.completionHandler?(.failed(error: error as NSError))
        ReceiptRefreshRequest.underlyingRequests[self.hash] = nil
    }
}
