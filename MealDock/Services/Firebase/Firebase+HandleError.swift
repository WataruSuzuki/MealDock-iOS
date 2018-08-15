//
//  Firebase+HandleError.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/16.
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
                self.alertErrorMessage(message: NSLocalizedString("requiresRecentLogin", comment: ""), actions: [action])
                
            default:
                break
            }
        }
    }
    
    private func alertErrorMessage(message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: "(=・A・=)!!", message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let root = delegate.window?.rootViewController {
            root.present(alert, animated: true, completion: nil)
        }
    }
}
