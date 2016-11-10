//
//  ProductQueryRequestsTests.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/26/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import XCTest
import StoreKit

class ProductQueryRequestsTests: XCTestCase {
    
    let TIMEOUT = 60.0
    
    let VALID_PRODUCT_ID1 = "com.funplus.sdk.product1"
    let VALID_PRODUCT_ID2 = "com.funplus.sdk.product2"
    let INVALID_PRODUCT_ID = "com.funplus.sdk.invalidproduct"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testQueryValidProductIdentifier() {
//        // Given
//        let productIdentifier = VALID_PRODUCT_ID1
//        let expectation = expectationWithDescription("FunPlusAppleIAP")
//        
//        // When
//        var products = [SKProduct]()
//        var invalidProductIdentifiers = [String]()
//        var error: ErrorType? = nil
//        
//        ProductQueryRequest(productIdentifiers: [productIdentifier]) { (result) in
//            products = result.products
//            invalidProductIdentifiers = result.invalidProductIdentifiers
//            error = result.error
//            
//            expectation.fulfill()
//        }.start()
//        
//        waitForExpectationsWithTimeout(TIMEOUT, handler: nil)
//        
//        // Then
//        XCTAssertEqual(products.count, 1, "count should be 1")
//        XCTAssertTrue(invalidProductIdentifiers.isEmpty, "isEmpty should be true")
//        XCTAssertNil(error, "error should be nil")
    }
    
    func testQueryValidProductIdentifiers() {
        
    }

    func testQueryMixedValidAndInvalidProductIdentifiers() {
        
    }
    
    func testQueryInvalidIdentifier() {
        
    }
    
    func testQueryInvalidIdentifiers() {
        
    }
    
}
