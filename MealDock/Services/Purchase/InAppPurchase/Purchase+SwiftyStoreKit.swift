//
//  Purchase+SwiftyStoreKit.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/20.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

extension PurchaseService {
    static let sharedSecret = "your-shared-secret"
    
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
        let indicator = UIViewController.topIndicatorStart()
        retrieveProductsInfo(productID: productID) { (result) in
            if let result = result {
                for product in result.retrievedProducts {
                    if productID.contains(product.productIdentifier) {
                        self.purchaseProduct(with: product, atomically: false)
                    }
                }
            }
            UIViewController.topIndicatorStop(view: indicator)
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
            if product.productId == UsageInfo.PurchasePlan.unlockPremium.productId()
                || product.productId == UsageInfo.PurchasePlan.unlockAd.productId()
            {
                verifyPurchase(productId: product.productId) { (verified) in
                    switch verified {
                    case .purchased( _):
                        UIViewController.snackBarMessage(text: NSLocalizedString("thank_you_for_purchase", comment: ""))
                    default:
                        break
                    }
                }
            } else {
                verifySubscriptions(productIds: [product.productId]) { (verified) in
                    switch verified {
                    case .purchased( _, _):
                        UIViewController.snackBarMessage(text: NSLocalizedString("thank_you_for_purchase", comment: ""))
                    default:
                        break
                    }
                }
            }
            
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
        let indicator = UIViewController.topIndicatorStart()
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            guard results.restoreFailedPurchases.count == 0 else {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                var message = "Restore Failed:"
                for restoreFailed in results.restoreFailedPurchases {
                    message.append("\n - \(restoreFailed)")
                }
                UIViewController.topIndicatorStop(view: indicator)
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
                    if purchase.productId == UsageInfo.PurchasePlan.unlockAd.productId()
                        || purchase.productId == UsageInfo.PurchasePlan.unlockPremium.productId()
                    {
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
            UIViewController.topIndicatorStop(view: indicator)
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
        let appleValidator = AppleReceiptValidator(service: type, sharedSecret: PurchaseService.sharedSecret)
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
        let indicator = UIViewController.topIndicatorStart()
        verifyReceipt { (info) in
            guard let receipt = info else {
                UIViewController.topIndicatorStop(view: indicator)
                completion(.notPurchased)
                return
            }
            // Verify the purchase of Consumable or NonConsumable
            let purchaseResult = SwiftyStoreKit.verifyPurchase(
                productId: productId,
                inReceipt: receipt)
            
            switch purchaseResult {
            case .purchased(let receiptItem):
                debugPrint("\(productId) is purchased: \(receiptItem)")
                switch productId {
                case UsageInfo.PurchasePlan.unlockAd.productId():
                    FirebaseService.shared.updateUnlockAdInfo(unlock: true)
                case UsageInfo.PurchasePlan.unlockPremium.productId():
                    FirebaseService.shared.updateUnlockPremiumInfo(unlock: true)
                default:
                    break
                }
            case .notPurchased:
                print("The user has never purchased \(productId)")
                switch productId {
                case UsageInfo.PurchasePlan.unlockAd.productId():
                    FirebaseService.shared.updateUnlockAdInfo(unlock: false)
                case UsageInfo.PurchasePlan.unlockPremium.productId():
                    FirebaseService.shared.updateUnlockPremiumInfo(unlock: false)
                default:
                    break
                }
            }
            UIViewController.topIndicatorStop(view: indicator)
            completion(purchaseResult)
        }
    }
    
    func verifySubscriptions(productIds: Set<String>, completion: @escaping (VerifySubscriptionResult) -> Void) {
        let indicator = UIViewController.topIndicatorStart()
        verifyReceipt { (info) in
            guard let receipt = info else {
                UIViewController.topIndicatorStop(view: indicator)
                completion(.notPurchased)
                return
            }
            let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
            switch purchaseResult {
            case .purchased(let expiryDate, let items):
                debugPrint("\(productIds) are valid until \(expiryDate)\n\(items)\n")
                FirebaseService.shared.updateSubscriptionPlanInfo(plan: .subscriptionBasic, expiryDate: expiryDate.timeIntervalSince1970)
                
            case .expired(let expiryDate, let items):
                print("\(productIds) are expired since \(expiryDate)\n\(items)\n")
                FirebaseService.shared.updateSubscriptionPlanInfo(plan: .free, expiryDate: nil)
                
            case .notPurchased:
                print("The user has never purchased \(productIds)")
            }
            UIViewController.topIndicatorStop(view: indicator)
            completion(purchaseResult)
        }
    }
}
