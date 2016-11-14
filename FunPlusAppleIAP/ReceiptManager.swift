//
//  ReceiptManager.swift
//  FunPlusAppleIAP
//
//  Created by Yuankun Zhang on 6/27/16.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
//import FunPlusSDK

public typealias Receipt = [String: AnyObject]

/**
    URL used to verify remotely receipt
 */
public enum ReceiptVerifyURL: String {
    case ProductionURL = "https://buy.itunes.apple.com/verifyReceipt"
    case SandboxURL = "https://sandbox.itunes.apple.com/verifyReceipt"
}

/**
    Status code returned by remote server.
 */
public enum ReceiptStatus: Int {
    
    /// Not decodable status.
    case unknown = -2
    
    /// No status returned.
    case none = -1
    
    /// valid status
    case valid = 0
    
    /// The App Store could not read the JSON object you provided.
    case jsonNotReadable = 21000
    
    /// The data in the receipt-data property was malformed or missing.
    case malformedOrMissingData = 21002
    
    /// The receipt could not be authenticated.
    case receiptCouldNotBeAuthenticated = 21003
    
    /// The shared secret you provided does not match the shared secret on file for your account.
    case secretNotMatching = 21004
    
    /// The receipt server is not currently available.
    case receiptServerUnavailable = 21005
    
    /// This receipt is valid but the subscription has expired. When this status code is returned
    /// to your server, the receipt data is also decoded and returned as part of the response.
    case subscriptionExpired = 21006
    
    /// This receipt is from the test environment, but it was sent to the production environment
    /// for verification. Send it to the test environment instead.
    case testReceipt = 21007
    
    /// This receipt is from the production environment, but it was sent to the test environment
    /// for verification. Send it to the production environment instead.
    case productionEnvironment = 21008
    
    var isValid: Bool { return self == .valid}
}

public enum ReceiptVerifyError: Error {
    
    /// No receipt data.
    case noReceiptData
    
    /// No remote receipt data.
    case noRemoteReceiptData
    
    /// Error when encoding HTTP body into JSON.
    case requestBodyEncodeError
    
    /// Error when retrieving the response data.
    case responseError
    
    /// Invalid receipt data.
    case invalidReceipt(receipt: Receipt, status: ReceiptStatus)
}

public enum ReceiptVerifyResult {
    case success(receipt: Receipt)
    case failed(error: ReceiptVerifyError)
}

public enum PurchaseVerifyResult {
    case purchased
    case notPurchased
}

public enum SubscriptionVerifyResult {
    case purchased(expiryDate: Date)
    case expired(expiryDate: Date)
    case notPurchased
}

open class ReceiptManager {
    
    static var receiptURL: URL? {
        return Bundle.main.appStoreReceiptURL
    }
    
    static var receiptData: Data? {
        guard
            let url = receiptURL,
            let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        
        return data
    }
    
    static var receiptBase64EncodedString: String? {
        return receiptData?.base64EncodedString(options: [])
    }
    
    /**
        See [Validate Receipt](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html)
     */
    class func verify(
        recepitVerifyURL url: ReceiptVerifyURL = .ProductionURL,
        password autoRenewPassword: String? = nil,
        completion: @escaping (ReceiptVerifyResult) -> Void)
    {
        // If no receipt is present, validation fails.
        guard let receiptBase64EncodedString = receiptBase64EncodedString else {
            completion(.failed(error: .noReceiptData))
            return
        }
        
        // Create the verification request.
        let storeURL = URL(string: url.rawValue)!
        let storeRequest = NSMutableURLRequest(url: storeURL)
        storeRequest.httpMethod = "POST"
        
        var requestContents = [
            "receipt-data": receiptBase64EncodedString
        ]
        
        if let password = autoRenewPassword {
            requestContents["password"] = password
        }
        
        // Encode the request body.
        do {
            storeRequest.httpBody = try JSONSerialization.data(withJSONObject: requestContents, options: [])
        } catch {
            completion(.failed(error: .requestBodyEncodeError))
            return
        }
        
        // TODO
//        Alamofire.request(storeRequest as! URLRequestConvertible).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                guard let receiptInfo = value as? Receipt, let statusCode = receiptInfo["status"] as? Int else {
//                    completion(.failed(error: .responseError))
//                    return
//                }
//                
//                let receiptStatus = ReceiptStatus(rawValue: statusCode) ?? ReceiptStatus.unknown
//                
//                guard receiptStatus.isValid else {
//                    completion(.failed(error: .invalidReceipt(receipt: receiptInfo, status: receiptStatus)))
//                    return
//                }
//                
//                completion(.success(receipt: receiptInfo))
//            case .failure(_):
//                completion(.failed(error: .responseError))
//            }
//        }
    }
    
    class func verifyPurchase(
        productIdentifier: String,
        inReceipt receipt: Receipt) -> PurchaseVerifyResult
    {
        let receipts = getReceiptsForProduct(productIdentifier: productIdentifier, inReceipt: receipt)
        
        return receipts.count > 0 ? .purchased : .notPurchased
    }
    
    class func verifySubscription(
        productIdentifier: String,
        inReceipt receipt: Receipt,
        validUntil date: Date = Date(),
        validDuration duration: TimeInterval? = nil) -> SubscriptionVerifyResult
    {
        let receipts = getReceiptsForProduct(productIdentifier: productIdentifier, inReceipt: receipt)
        
        if receipts.count == 0 {
            return .notPurchased
        }
        
        let expiryDateValues = receipts
            .flatMap { receipt -> String? in
                let key: String = duration != nil ? "original_purchase_date_ms" : "expires_date_ms"
                return receipt[key] as? String
            }
            .flatMap { dateString -> Date? in
                guard let doubleValue = Double(dateString) else { return nil }
                // If duration is set, create an "expires date" value calculated from the original purchase date.
                let addedDuration = duration ?? 0
                let expiryDateDouble = (doubleValue / 1000 + addedDuration)
                return Date(timeIntervalSince1970: expiryDateDouble)
            }
            .sorted { (a, b) -> Bool in
                // Sort by descending date order.
                return a.compare(b) == .orderedDescending
            }
        
        guard let firstExpiryDate = expiryDateValues.first else {
            return .notPurchased
        }
        
        // Check if at least 1 receipt is valid.
        if firstExpiryDate.compare(date) == .orderedDescending {
            // The subscription is valid.
            return .purchased(expiryDate: firstExpiryDate)
        } else {
            // The subscription is expired.
            return .expired(expiryDate: firstExpiryDate)
        }

    }
    
    fileprivate class func getReceiptsForProduct(
        productIdentifier: String,
        inReceipt receipt: Receipt) -> [Receipt]
    {
        guard let allReceipts = receipt["receipt"]?["in_app"] as? [Receipt] else {
            return []
        }
        
        return allReceipts.filter { receipt -> Bool in
            return productIdentifier == receipt["product_id"] as? String
        }
    }
}
