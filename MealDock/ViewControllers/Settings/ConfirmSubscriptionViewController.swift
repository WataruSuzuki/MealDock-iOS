//
//  ConfirmSubscriptionViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/11/15.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import StoreKit
import SafariServices

class ConfirmSubscriptionViewController: UITableViewController {
    
    var plan: UsageInfo.PurchasePlan!
    var retrievedProduct: SKProduct?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        PurchaseService.shared.retrieveProductInfo(productID: plan.productId()) { (product) in
            guard let product = product else {
                let action = UIAlertAction(title: "OK", style: .default, handler: { (actopm) in
                    self.navigationController?.popViewController(animated: true)
                })
                OptionalError.alertErrorMessage(message: NSLocalizedString("", comment: ""), actions: [action])
                return
            }
            self.retrievedProduct = product
            self.tableView.reloadData()
            self.navigationItem.title = product.localizedTitle
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return AutoRenewableNature.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let nature = AutoRenewableNature(rawValue: section) {
            switch nature {
            case .aboutThisApp:
                return SettingsViewController.AboutThisApp.max.rawValue
            default:
                break
            }
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmSubscriptionCell", for: indexPath)

        // Configure the cell...
        if let nature = AutoRenewableNature(rawValue: indexPath.section) {
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = NSLocalizedString("description_" + nature.description(), comment: "")
            cell.detailTextLabel?.text = ""
            
            switch nature {
            case .timePeriod:
                cell.textLabel?.text = NSLocalizedString("valid_until", comment: "")
                if let expireDate = FirebaseService.shared.currentUser?.usageInfo?.expireDate {
                    cell.detailTextLabel?.text = Date(timeIntervalSince1970: expireDate).formattedString()
                } else {
                    cell.detailTextLabel?.text = "- - -"
                }
            case .aboutThisService:
                if let product = retrievedProduct {
                    cell.textLabel?.numberOfLines = 1
                    cell.textLabel?.text = product.localizedTitle
                    cell.detailTextLabel?.text = product.localizedPrice
                }
            case .aboutThisApp:
                if let aboutThisApp = SettingsViewController.AboutThisApp(rawValue: indexPath.row) {
                    cell.textLabel?.text = NSLocalizedString(aboutThisApp.description(), comment: "")
                }
            default:
                break
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let nature = AutoRenewableNature(rawValue: section) else { return nil }
        return NSLocalizedString(nature.description(), comment: "")
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let nature = AutoRenewableNature(rawValue: section) {
            if nature == .aboutThisService, let product = retrievedProduct {
                let key = "footer_" + plan.description()
                return product.localizedDescription + "\n" + String(format: NSLocalizedString(key, comment: ""), plan.limitSize(), UsageInfo.PurchasePlan.free.limitSize())
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nature = AutoRenewableNature(rawValue: indexPath.section) else { return }
        switch nature {
        case .aboutThisService:
            tapPurchase()
        case .aboutThisApp:
            if let aboutThis = SettingsViewController.AboutThisApp(rawValue: indexPath.row) {
                switch aboutThis {
                case .terms:
                    present(SFSafariViewController(url: URL(string: AppDelegate.termsUrl)!), animated: true, completion: nil)
                case .privacyPolicy:
                    present(SFSafariViewController(url: URL(string: AppDelegate.privacyPolicyUrl)!), animated: true, completion: nil)
                default:
                    break
                }
            }
        default:
            break
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tapPurchase() {
        PurchaseService.shared.validateProduct(productID: [plan.productId()], atomically: false) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    enum AutoRenewableNature: Int {
        case timePeriod = 0,
        aboutThisService,
        aboutAppStoreSubscription,
        aboutThisApp,
        max
    }
}
