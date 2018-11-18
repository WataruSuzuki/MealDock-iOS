//
//  Purchase+Recommend.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/11/18.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

extension PurchaseService {
    func alertCapacity() {
        OptionalError.alertErrorMessage(message: NSLocalizedString("failed_of_limit_capacity", comment: ""), actions: getActions())
    }
    
    private func getActions() -> [UIAlertAction]? {
        guard let user = FirebaseService.shared.currentUser, user.isPurchased else {
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            let recommendAction = UIAlertAction(title: NSLocalizedString("upgrade", comment: ""), style: .default) { (action) in
                DispatchQueue.main.async {
                    let sb = UIStoryboard(name: "Purchase", bundle: Bundle.main)
                    if let viewController = sb.instantiateViewController(withIdentifier: String(describing: PurchaseMenuViewController.self)) as? PurchaseMenuViewController {
                        let navigation = UINavigationController.init(rootViewController: viewController)
                        if let top = UIViewController.currentTop() {
                            top.present(navigation, animated: true, completion: nil)
                        }
                    }
                }
            }
            return [cancelAction, recommendAction]
        }
        return nil
    }
}
