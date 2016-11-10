//
//  ProductPurchaseRequest.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/27/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - ProductPurcahseError

/**
    The `ProductPurcahseError` enum represents errors which can be occurred
    when a product purchasing process is being taken out.
 */
public enum ProductPurchaseError : Error {
    
    /// Unknow fatal error.
    case unknownFatalError
    
    /// Do not have the permission to purchase.
    case paymentNotAllowed
    
    /// Failed to query product information.
    case productQueryFailed
    
    /// Empty product identifier is given.
    case emptyProductIdentifier
    
    /// Invalid product identifier is given.
    case invalidProductIdentifier
    
    /// Error when the purchase request is carrying out.
    case purchaseError(NSError)
}

// MARK: - ProductPurchaseResult

/**
    The `ProductPurchaseResult` enum represents results which will be passed
    back to the completion handler.
 */
public enum ProductPurchaseResult {
    
    /// The purchase is succeeded.
    case success(transaction: SKPaymentTransaction)
    
    /// The purchase is failed.
    case failed(error: ProductPurchaseError)
}

// MARK: - ProductPurchaseRequestDelegate

/**
    The `ProductPurchaseRequestDelegate` class contains a set of handlers which
    will be called at certain moment.
 */
class ProductPurchaseRequestDelegate : NSObject {
    
    /// This handler will be triggered in the process of purchase.
    var progressHandler: (() -> Void)?
    
    /// This handler will be triggered when the purchase is finished.
    var completionHandler: ((ProductPurchaseResult) -> Void)?
}

// MARK: - ProductPurchaseRequest

/**
    The `ProductPurchaseRequest` represents a request that purchase products.
 
    See [Requesting Payment](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/RequestPayment.html#//apple_ref/doc/uid/TP40008267-CH4-SW2)
 */
open class ProductPurchaseRequest {
    
    /// The identifier of product to purchase.
    let productIdentifier: String
    
    /// The quantity of product to purchase.
    let quantity: Int
    
    /// The application username along with the transaction.
    /// See [applicationUsername](https://developer.apple.com/library/ios/documentation/StoreKit/Reference/SKPaymentRequest_Class/index.html#//apple_ref/occ/instp/SKPayment/applicationUsername)
    let applicationUsername: String
    
    /// The request delegate.
    var purchaseRequestDelegate = ProductPurchaseRequestDelegate()
    
    /**
        Construct a new `ProductPurchaseRequest` instance with the given parameters.
     
        - parameter productIdentifier:      The identifier of product to purchase.
        - parameter quantity:               The quantity of product to purchase.
        - parameter applicationUsername:    The application username.
     
        - returns:  The created instance.
     */
    init(productIdentifier: String, quantity: Int, applicationUsername: String) {
        self.productIdentifier = productIdentifier
        self.quantity = quantity
        self.applicationUsername = applicationUsername
    }
    
    /**
        Set an in-progress handler to the request delegate.
     
        - parameter handler:    The in-progress handler to be set.
     
        - returns:  The request itself.
     */
    open func progress(_ handler: @escaping () -> Void) -> ProductPurchaseRequest {
        self.purchaseRequestDelegate.progressHandler = handler
        return self
    }
    
    /**
        Set a completion handler to the request delegate and start the request.
     
        - parameter handler:    The completion handler to be set.
     */
    open func complete(_ handler: @escaping (ProductPurchaseResult) -> Void) {
        // Identifier is empty?
        guard !productIdentifier.isEmpty else {
            handler(.failed(error: .emptyProductIdentifier))
            return
        }
        
        self.purchaseRequestDelegate.completionHandler = handler
        
        // Query the product information first.
        ProductQueryRequest(productIdentifiers: [productIdentifier]).complete({ result in
            switch result {
            case .success(let products, let invalidProductIdentifiers):
                // Identifier is invalid?
                guard invalidProductIdentifiers.isEmpty else {
                    handler(.failed(error: .invalidProductIdentifier))
                    return
                }
                
                guard let product = products.first else {
                    // Should never reach here.
                    handler(.failed(error: .unknownFatalError))
                    return
                }
                
                // Start the purchase process.
                PaymentQueueProxy.sharedInstance.purchaseProduct(
                    product: product,
                    quantity: self.quantity,
                    applicationUsername: self.applicationUsername,
                    purchaseRequestDelegate: self.purchaseRequestDelegate
                )
            case .failed(_):
                // Oops, failed to query product.
                handler(.failed(error: .productQueryFailed))
            }
        })
    }
}
