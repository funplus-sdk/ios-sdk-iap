//
//  ProductQueryRequest.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/27/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - ProductQueryError

/**
    The `ProductQueryError` enum represents errors which can be occurred
    when a products quering process is being taken out.
 */
public enum ProductQueryError : Error {
    
    /// The identifiers array to be queried is empty.
    case emptyProductIdentifiers
    
    /// Error when requesting to App Store.
    case queryError(NSError)
}

// MARK: - ProductQueryResult

/**
    The `ProductQueryResult` enum represents results which will be passed
    back to the completion handler.
 */
public enum ProductQueryResult {
    
    /// Success with the rsults we want.
    case success(products: [SKProduct], invalidProductIdentifiers: [String])
    
    /// Failed with an error which explains the failure.
    case failed(error: ProductQueryError)
}

// MARK: - ProductQueryRequest

/**
    The `ProductQueryRequest` represents a request that queries products
    information including display name, price and currency code.
 
    See [Retrieving Product Information](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/ShowUI.html#//apple_ref/doc/uid/TP40008267-CH3-SW5)
 */
open class ProductQueryRequest : NSObject, SKProductsRequestDelegate {
    
    // MARK: - Properties
    
    /// The container to cache all the underlying requests.
    static var underlyingRequests = [Int: ProductQueryRequest]()
    
    /// The products whose information has already been queried.
    static var queriedProducts = [String: SKProduct]()
    
    /// The product identifiers to be queried.
    let productIdentifiers: [String]
    
    /// The underlying request.
    var request: SKProductsRequest?
    
    /// The completion handler.
    var completionHandler: ((ProductQueryResult) -> Void)?
    
    // MARK: - Init & Deinit
    
    /**
        Construct a new `ProductQueryRequest` instance with the given product identifiers.
     
        - parameter productIdentifiers:     The product identifiers to query.
     
        - returns:  The created instance.
     */
    init(productIdentifiers: [String]) {
        self.productIdentifiers = productIdentifiers
        self.request = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        
        super.init()
        ProductQueryRequest.underlyingRequests[self.hash] = self
    }
    
    deinit {
        self.request?.delegate = nil
    }
    
    // MARK: - Operations
    
    /**
        Set a completion handler and start the request (or directly return if any error occurs).
     
        - parameter handler:    The completion handler.
     */
    open func complete(_ handler: @escaping (ProductQueryResult) -> Void) {
        // Identifier is empty?
        guard !productIdentifiers.isEmpty else {
            handler(.failed(error: .emptyProductIdentifiers))
            return
        }
        
        var productsToReturn = [SKProduct]()
        var identifiersToQuery = [String]()
        
        for identifier in productIdentifiers {
            if let product = ProductQueryRequest.queriedProducts[identifier] {
                productsToReturn.append(product)
            } else {
                identifiersToQuery.append(identifier)
            }
        }
        
        // Products have already been queried?
        if identifiersToQuery.isEmpty {
            handler(.success(products: productsToReturn, invalidProductIdentifiers: []))
            return
        }
        
        self.completionHandler = handler
        
        // Create a new request and start it.
        self.request = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        self.request?.delegate = self
        self.request?.start()
    }
    
    // MARK: - SKProductsRequestDelegate
    
    /**
        Response received.
     
        - parameter request:        The correlative request.
        - parameter complete:       The complete.
     */
    open func productsRequest(_ request: SKProductsRequest, didReceive complete: SKProductsResponse) {
        self.completionHandler?(.success(
            products: complete.products,
            invalidProductIdentifiers: complete.invalidProductIdentifiers
        ))
    }
    
    /**
        Request finished. Remove it from the requests container.
     
        - parameter request:        The correlative request.
     */
    open func requestDidFinish(_ request: SKRequest) {
        ProductQueryRequest.underlyingRequests[self.hash] = nil
    }
    
    /**
        Request failed.
     
        - parameter request:        The correlative request.
        - parameter error:          The error which causes the failure.
     */
    open func request(_ request: SKRequest, didFailWithError error: Error) {
        requestFailed(error as NSError)
    }
    
    /**
        Request failed.
     
        - parameter error:          The error which causes the failure.
     */
    open func requestFailed(_ error: NSError){
        self.completionHandler?(.failed(error: .queryError(error)))
        ProductQueryRequest.underlyingRequests[self.hash] = nil
    }
}
