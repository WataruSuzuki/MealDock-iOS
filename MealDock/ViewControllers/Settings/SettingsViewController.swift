//
//  SettingsViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "settings".localized

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = FirebaseService.shared.currentUser, !user.isPurchased {
            self.tableView.reloadRows(at: [IndexPath(item: 0, section: Sections.ticket.rawValue)], with: .automatic)
        }        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Sections.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let sections = Sections(rawValue: section) {
            switch sections {
            case .account:
                return AccountRow.max.rawValue
            case .aboutThisApp:
                return AboutThisApp.max.rawValue
            case .ticket:
                let isFreeUser = !(FirebaseService.shared.currentUser?.isPurchased ?? true)
                return (isFreeUser ? TicketMenu.max.rawValue : 0)
            case .purchase: fallthrough
            case .signOut:
                return 1
            default:
                break
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        cell.detailTextLabel?.text = ""
        cell.accessoryType = .none

        // Configure the cell...
        if let section = Sections(rawValue: indexPath.section) {
            cell.accessoryType = .disclosureIndicator
            switch section {
            case .account:
                if let accountRow = AccountRow(rawValue: indexPath.row) {
                    cell.textLabel?.text = accountRow.description().localized
                }
            case .aboutThisApp:
                if let aboutThisRow = AboutThisApp(rawValue: indexPath.row) {
                    cell.textLabel?.text = aboutThisRow.description().localized
                }
            case .ticket:
                if let ticketMenu = TicketMenu(rawValue: indexPath.row) {
                    cell.textLabel?.text = ticketMenu.description().localized
                    let current =
                        UserDefaults.standard.object(forKey: PurchaseService.keyTicket) as? Int ?? 0
                    cell.detailTextLabel?.text = "current_ticket".localized + ": \(current)" 
                    cell.accessoryType = .none
                }
            case .purchase:
                cell.textLabel?.text = section.description().localized
            case .signOut:
                cell.textLabel?.text = section.description().localized
                fallthrough
            default:
                break
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = Sections(rawValue: section) {
            let isPurchased = (FirebaseService.shared.currentUser?.isPurchased ?? true)
            if sections != .signOut && sections != .purchase
                && !(sections == .ticket && isPurchased)
            {
                return sections.description().localized
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let sections = Sections(rawValue: section) {
            let isFreeUser = !(FirebaseService.shared.currentUser?.isPurchased ?? true)
            if sections == .ticket && isFreeUser {
                return "footer_reward".localized
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard FirebaseService.shared.currentUser != nil else {
            FirebaseService.shared.requestAuthUI()
            return
        }
        
        if let section = Sections(rawValue: indexPath.section) {
            switch section {
            case .account:
                if let accountRow = AccountRow(rawValue: indexPath.row) {
                    switch accountRow {
                    case .userInfo:
                        performSegue(withIdentifier: String(describing: UsageInfoViewController.self), sender: self)
                    case .groupInfo:
                        performSegue(withIdentifier: String(describing: GroupInfoViewController.self), sender: self)
                        GroupInfoViewController.description()
                    default:
                        break
                    }
                }
                break
            case .aboutThisApp:
                if let aboutThis = AboutThisApp(rawValue: indexPath.row) {
                    switch aboutThis {
                    case .terms:
                        present(SFSafariViewController(url: URL(string: AppDelegate.termsUrl)!), animated: true, completion: nil)
                    case .privacyPolicy:
                        present(SFSafariViewController(url: URL(string: AppDelegate.privacyPolicyUrl)!), animated: true, completion: nil)
                    default:
                        break
                    }
                }
            case .ticket:
                if let ticketMenu = TicketMenu(rawValue: indexPath.row) {
                    switch ticketMenu {
                    case .rewared:
                        PurchaseService.shared.showReward(rootViewController: self)
                        break
                    default:
                        break
                    }
                }
            case .purchase:
                performSegue(withIdentifier: String(describing: PurchaseMenuViewController.self), sender: self)
            case .signOut:
                FirebaseService.shared.signOut()
                
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    enum Sections: Int {
        case account = 0,
        aboutThisApp,
        ticket,
        purchase,
        signOut,
        max
    }
    
    enum AccountRow: Int {
        case userInfo = 0,
        groupInfo,
        max
    }
    
    enum AboutThisApp: Int {
        case terms = 0,
        privacyPolicy,
        //help,
        max
    }
    
    enum TicketMenu: Int {
        case rewared = 0,
        max
    }
}
