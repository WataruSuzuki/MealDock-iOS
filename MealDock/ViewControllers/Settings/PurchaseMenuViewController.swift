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
        
        if isModal {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDismiss))
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return UsageInfo.PurchasePlan.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseMenuCell", for: indexPath)

        // Configure the cell...
        if let menu = UsageInfo.PurchasePlan(rawValue: indexPath.section) {
            if menu == .free {
                cell.textLabel?.text = NSLocalizedString("restore", comment: "")
            } else {
                cell.textLabel?.text = NSLocalizedString(menu.description(), comment: "")
            }
            cell.accessoryType = (menu == .subscriptionBasic ? .disclosureIndicator : .none)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let menu = UsageInfo.PurchasePlan(rawValue: section) {
            let key = "footer_" + menu.description()
            switch menu {
            case .free:
                return NSLocalizedString("footer_restore", comment: "")
            case .unlockPremium:
                return String(format: NSLocalizedString(key, comment: ""), UsageInfo.PurchasePlan.unlockPremium.limitSize(), UsageInfo.PurchasePlan.free.limitSize())
            case .subscriptionBasic:
                return nil
            default:
                return NSLocalizedString(key, comment: "")
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = UsageInfo.PurchasePlan(rawValue: indexPath.section) {
            switch menu {
            case .free:
                PurchaseService.shared.restorePurchases()
                break
            case .unlockAd:
                PurchaseService.shared.validateProduct(productID: [UsageInfo.PurchasePlan.unlockAd.productId()], atomically: false, completion: {})
            case .unlockPremium:
                PurchaseService.shared.validateProduct(productID: [UsageInfo.PurchasePlan.unlockPremium.productId()], atomically: false, completion: {})
            case .subscriptionBasic:
                performSegue(withIdentifier: String(describing: ConfirmSubscriptionViewController.self), sender: self)
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case String(describing: ConfirmSubscriptionViewController.self):
                if let destination = segue.destination as? ConfirmSubscriptionViewController {
                    destination.plan = .subscriptionBasic
                }
            default:
                break
            }
        }
    }
}
