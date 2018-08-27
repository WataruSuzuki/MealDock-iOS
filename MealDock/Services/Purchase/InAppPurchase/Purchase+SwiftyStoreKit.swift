//
//  Purchase+SwiftyStoreKit.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/20.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

extension PurchaseService {
    
    //Note that completeTransactions() should only be called once in your code
    func completeTransactions() {
    //func completeTransactions(completion: @escaping ([Purchase]) -> Void) {
        // see notes below for the meaning of Atomic / Non-Atomic
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
    
    func validateProduct(productID: Set<String>, atomically: Bool) {
        retrieveProductsInfo(productID: productID) { (result) in
            if let result = result {
                for product in result.retrievedProducts {
                    if productID.contains(product.productIdentifier) {
                        self.purchaseProduct(with: product, atomically: false)
                    }
                }
            }
        }
    }
    
    private func retrieveProductsInfo(productID: Set<String>, completion: @escaping (RetrieveResults?) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(productID) { result in
            guard result.error == nil else {
                OptionalError.alertErrorMessage(error: result.error!)
                completion(nil)
                return
            }
            if result.invalidProductIDs.count > 0 {
                var message = "Invalid product identifier:"
                for invalidProduct in result.invalidProductIDs {
                    message.append("\n - \(invalidProduct)")
                }
                OptionalError.alertErrorMessage(message: message, actions: nil)
            }
            for product in result.retrievedProducts {
                let priceString = product.localizedPrice!
                debugPrint("Product: \(product.localizedDescription), price: \(priceString)")
            }
            completion(result)
        }
    }
    
    private func purchaseProduct(with product: SKProduct, atomically: Bool) {
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: atomically) { result in
            self.handlePurchaseResult(result: result, atomically: atomically)
        }
    }
    
    
    func purchaseProduct(with id: String, atomically: Bool) {
        SwiftyStoreKit.purchaseProduct(id, quantity: 1, atomically: atomically) { result in
            self.handlePurchaseResult(result: result, atomically: atomically)
        }
    }
    
    private func handlePurchaseResult(result: PurchaseResult, atomically: Bool) {
        switch result {
        case .success(let product):
            // fetch content from your server, then:
            if !atomically && product.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(product.transaction)
            }
            debugPrint("Purchase Success: \(product.productId)")
            UIViewController.snackBarMessage(text: NSLocalizedString("thank_you_for_purchase", comment: ""))
            
        case .error(let error):
            switch error.code {
            case .paymentCancelled:
                //Unnecessary to alert error
                return
            case .unknown: print("Unknown error. Please contact support")
            case .clientInvalid: print("Not allowed to make the payment")
            case .paymentInvalid: print("The purchase identifier was invalid")
            case .paymentNotAllowed: print("The device is not allowed to make the payment")
            case .storeProductNotAvailable: print("The product is not available in the current storefront")
            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
            }
            OptionalError.alertErrorMessage(error: error)
        }
    }
    
    func restorePurchases() {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            guard results.restoreFailedPurchases.count == 0 else {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                var message = "Restore Failed:"
                for restoreFailed in results.restoreFailedPurchases {
                    message.append("\n - \(restoreFailed)")
                }
                OptionalError.alertErrorMessage(message: message, actions: nil)
                return
            }
            if results.restoredPurchases.count > 0 {
                var productIDs = Set<String>()
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    if purchase.productId == Bundle.main.bundleIdentifier! + "." + UsageInfo.PurchasePlan.unlockAd.description() {
                        self.verifyPurchase(productId: purchase.productId, completion: { (verified) in
                            switch verified {
                            case .purchased(let item):
                                self.restoredMessage(item: item)
                            default:
                                break
                            }
                        })
                    } else {
                        productIDs.update(with: purchase.productId)
                    }
                }
                self.verifySubscriptions(productIds: productIDs, completion: { (verified) in
                    switch verified {
                    case .purchased( _, let items):
                        for item in items {
                            self.restoredMessage(item: item)
                        }
                        break
                    default:
                        break
                    }
                })
                debugPrint("Restore Success: \(results.restoredPurchases)")
            } else {
                print("Nothing to Restore")
                OptionalError.alertErrorMessage(message: "cannot_find_paid_history", actions: nil)
            }
        }
    }
    
    private func restoredMessage(item: ReceiptItem) {
        var itemName = ""
        if let range = item.productId.range(of: Bundle.main.bundleIdentifier! + ".") {
            itemName = item.productId
            itemName.replaceSubrange(range, with: "")
        }
        UIViewController.snackBarMessage(text: NSLocalizedString("comp_restore", comment: "")
            + "\n" + NSLocalizedString(itemName, comment: ""))
    }
    
    func fetchReceipt(force: Bool, completion: @escaping (String?) -> Void) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: force) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                debugPrint("Fetch receipt success:\n\(encryptedReceipt)")
                completion(encryptedReceipt)
            case .error(let error):
                print("Fetch receipt failed: \(error)")
                completion(nil)
            }
        }
    }
    
    func verifyReceipt(completion: @escaping (ReceiptInfo?) -> Void) {
        fetchReceipt(force: false) { (base64EncodedReceipt) in
            self.validateReceipt(type: .production, completion: completion)
        }
    }
    
    func validateReceipt(type: AppleReceiptValidator.VerifyReceiptURLType, isRetrySandBox: Bool = false, completion: @escaping (ReceiptInfo?) -> Void) {
        let appleValidator = AppleReceiptValidator(service: type, sharedSecret: "your-shared-secret")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            switch result {
            case .success(let receipt):
                debugPrint("Verify receipt success: \(receipt)")
                completion(receipt)
                
            case .error(let error):
                print("Verify receipt failed: \(error)")
            }
        }
    }
    
    func verifyPurchase(productId: String, completion: @escaping (VerifyPurchaseResult) -> Void) {
        verifyReceipt { (info) in
            guard let receipt = info else {
                completion(.notPurchased)
                return
            }
            // Verify the purchase of Consumable or NonConsumable
            let purchaseResult = SwiftyStoreKit.verifyPurchase(
                productId: productId,
                inReceipt: receipt)
            
            switch purchaseResult {
            case .purchased(let receiptItem):
                print("\(productId) is purchased: \(receiptItem)")
            case .notPurchased:
                print("The user has never purchased \(productId)")
            }
            completion(purchaseResult)
        }
    }
    
    func verifySubscriptions(productIds: Set<String>, completion: @escaping (VerifySubscriptionResult) -> Void) {
        verifyReceipt { (info) in
            guard let receipt = info else {
                completion(.notPurchased)
                return
            }
            let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
            switch purchaseResult {
            case .purchased(let expiryDate, let items):
                print("\(productIds) are valid until \(expiryDate)\n\(items)\n")
            case .expired(let expiryDate, let items):
                print("\(productIds) are expired since \(expiryDate)\n\(items)\n")
            case .notPurchased:
                print("The user has never purchased \(productIds)")
            }
            completion(purchaseResult)
        }
    }
}
