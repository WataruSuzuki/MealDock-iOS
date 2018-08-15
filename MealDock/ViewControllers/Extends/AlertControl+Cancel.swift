//
//  AlertControl+Cancel.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    func addCancelAction(handler: ((UIAlertAction) -> Void)?) {
        let action = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: handler)
        self.addAction(action)
    }
    
    func addEmptyCancelAction() {
        addCancelAction(handler: nil)
    }
}
