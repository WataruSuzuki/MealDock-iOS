//
//  Firebase+HandleError.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/16.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func handleError(error: Error?, funcName: String) {
        print(error ?? OptionalError.kaomojiErrorStr(funcName: funcName))
        if let error = error {
            print(error)
            guard let errorCode = AuthErrorCode(rawValue: error._code) else { return }
            switch errorCode {
            case .requiresRecentLogin:
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.signOut()
                })
                OptionalError.alertErrorMessage(message: NSLocalizedString("requiresRecentLogin", comment: ""), actions: [action])
                
            default:
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                OptionalError.alertErrorMessage(message: "(Φ人Φ) Error code: \(errorCode)", actions: [action])
                break
            }
        }
    }
}
