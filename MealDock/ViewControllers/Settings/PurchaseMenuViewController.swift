//
//  PurchaseMenuViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/19.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

class PurchaseMenuViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Menu.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseMenuCell", for: indexPath)

        // Configure the cell...
        if let menu = Menu(rawValue: indexPath.section) {
            cell.textLabel?.text = NSLocalizedString(menu.description(), comment: "")
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let menu = Menu(rawValue: section) {
            let key = "footer_" + menu.description()
            switch menu {
            case .unlockAd:
                return String(format: NSLocalizedString(key, comment: ""), UsageInfo.PurchasePlan.unlockAd.limitSize(), UsageInfo.PurchasePlan.free.limitSize())
            case .subscription:
                return String(format: NSLocalizedString(key, comment: ""), UsageInfo.PurchasePlan.subscription.limitSize())
            default:
                return NSLocalizedString(key, comment: "")
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = Menu(rawValue: indexPath.section) {
            switch menu {
            case .restore:
                PurchaseService.shared.restorePurchases()
                break
            case .unlockAd:
                PurchaseService.shared.validateProduct(productID: [UsageInfo.PurchasePlan.unlockAd.productId()], atomically: false)
            case .subscription:
                PurchaseService.shared.validateProduct(productID: [UsageInfo.PurchasePlan.subscription.productId()], atomically: false)
            default:
                break
            }
        }
    }

    enum Menu: Int {
        case unlockAd = 0,
        subscription,
        restore,
        max
    }
}
