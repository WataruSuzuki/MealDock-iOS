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
                    case .changeEmail: fallthrough
                    case .changeDisplayName:
                        showInputNewInfoController(row: editRow)
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
    
    func showInputNewInfoController(row: EditAccount) {
        var keyboard = UIKeyboardType.default
        var content: UITextContentType!
        var msg = "";
        switch row {
        case .changeEmail:
            keyboard = .emailAddress
            if #available(iOS 10.0, *) {
                content = .emailAddress
            }
            msg = "msg_change_email"
        case .changeDisplayName:
            if #available(iOS 10.0, *) {
                content = .nickname
            }
            msg = "msg_change_displayname"
        default:
            return
        }
        let controller = UIAlertController(title: "(・∀・)", message: NSLocalizedString(msg, comment: ""), preferredStyle: .alert)
        controller.addEmptyCancelAction()
        controller.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.keyboardType = keyboard
            if #available(iOS 10.0, *) {
                text.textContentType = content
            }
        })
        let completeAction:UIAlertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.updateUserInfoByNewStr(row: row, alert: controller)
        }
        controller.addAction(completeAction)
        present(controller, animated: true, completion: nil)
    }
    
    func updateUserInfoByNewStr(row: EditAccount, alert: UIAlertController) {
        if let textFields = alert.textFields {
            if textFields.count > 0 {
                guard let newStr = textFields[0].text else { return }
                debugPrint(newStr)
                switch row {
                case .changeEmail:
                    FirebaseService.shared.updateEmail(newEmail: newStr)
                case .changeDisplayName:
                    FirebaseService.shared.updateProfile(displayName: newStr)
                default:
                    break
                }
            }
        }
    }
    
    private func getUserInfoDetailStr(index: UserInfo) -> String {
        if let user = FirebaseService.shared.currentUser {
            switch index {
            case .displayName:
                return user.core.displayName ?? ""
            case .email:
                return user.core.email ?? ""
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
