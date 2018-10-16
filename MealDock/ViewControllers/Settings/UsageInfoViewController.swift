//
//  UsageInfoViewController.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/16.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

class UsageInfoViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = Sections(rawValue: section) {
            switch sections {
            case .userInfo:
                return UserInfo.max.rawValue
            case .editAccount:
                return EditAccount.max.rawValue
            case .deleteAccount:
                return 1
            default:
                break
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsageInfoCell", for: indexPath)

        // Configure the cell...
        if let sections = Sections(rawValue: indexPath.section) {
            cell.textLabel?.textColor = .black
            switch sections {
            case .userInfo:
                if let userInfoRow = UserInfo(rawValue: indexPath.row) {
                    cell.textLabel?.text = NSLocalizedString(userInfoRow.description(), comment: "")
                    cell.detailTextLabel?.text = getUserInfoDetailStr(index: userInfoRow)
                }
            case .editAccount:
                if let editAccountRow = EditAccount(rawValue: indexPath.row) {
                    cell.textLabel?.text = NSLocalizedString(editAccountRow.description(), comment: "")
                }
            case .deleteAccount:
                cell.textLabel?.text = NSLocalizedString(sections.description(), comment: "")
                cell.textLabel?.textColor = .red
            default:
                break
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = Sections(rawValue: section) {
            if sections != .deleteAccount {
                return NSLocalizedString(sections.description(), comment: "")
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sections = Sections(rawValue: indexPath.section) {
            switch sections {
            case .deleteAccount:
                FirebaseService.shared.deleteCurrentUser()
                
            case .editAccount:
                if let editRow = EditAccount(rawValue: indexPath.row) {
                    switch editRow {
                    case .resetPassword:
                        FirebaseService.shared.sendPasswordReset()
                    default:
                        break
                    }
                }

            case .userInfo: fallthrough
            default:
                break
            }
        }
        
    }

    private func getUserInfoDetailStr(index: UserInfo) -> String {
        if let user = FirebaseService.shared.currentUser {
            switch index {
            case .displayName:
                return user.displayName ?? ""
            case .email:
                return user.email ?? ""
            case .password:
                return "*****************"
            default:
                break
            }
        }
        return ""
    }
    
    enum Sections: Int {
        case userInfo = 0,
        editAccount,
        deleteAccount,
        max
    }
    
    enum UserInfo: Int {
        case displayName = 0,
        email,
        password,
        max
    }
    
    enum EditAccount: Int {
        case changeDisplayName = 0,
        changeEmail,
        resetPassword,
        max
    }
}
