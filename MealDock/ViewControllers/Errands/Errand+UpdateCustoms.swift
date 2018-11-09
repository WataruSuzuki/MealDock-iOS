//
//  Errand+UpdateCustoms.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/12/19.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

protocol UpdateCustomMarketItemDelegate {
    func updatedItem()
}

extension ErrandPagingViewController : UpdateCustomMarketItemDelegate {
    
    func updatedItem() {
        FirebaseService.shared.loadMarketItems(success: { (items) in
            self.items = items
            DispatchQueue.main.async {
                self.removePagingViews()
                self.instatiatePavingViews()
                self.view.bringSubview(toFront: self.bottomBarView)
                self.dismiss(animated: true, completion: nil)
            }
        }) { (error) in
            OptionalError.alertErrorMessage(error: error)
        }
    }
    
}
