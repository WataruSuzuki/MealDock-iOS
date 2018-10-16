//
//  Firebase+HandleError.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/16.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func alertErrorMessage(message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: "(=・A・=)!!", message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let root = delegate.window?.rootViewController {
            root.present(alert, animated: true, completion: nil)
        }
    }
}
