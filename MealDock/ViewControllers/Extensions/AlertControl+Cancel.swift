//
//  AlertControl+Cancel.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/17.
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
    
    func addEmptyOkAction() {
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        self.addAction(action)
    }
}
