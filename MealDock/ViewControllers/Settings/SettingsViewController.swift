//
//  SettingsViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("settings", comment: "")

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

        // Configure the cell...
        if let section = Sections(rawValue: indexPath.section) {
            cell.accessoryType = .disclosureIndicator
            switch section {
            case .account:
                if let accountRow = AccountRow(rawValue: indexPath.row) {
                    cell.textLabel?.text = NSLocalizedString(accountRow.description(), comment: "")
                }
            case .aboutThisApp:
                if let aboutThisRow = AboutThisApp(rawValue: indexPath.row) {
                    cell.textLabel?.text = NSLocalizedString(aboutThisRow.description(), comment: "")
                }
            case .signOut:
                cell.textLabel?.text = NSLocalizedString(section.description(), comment: "")
                fallthrough
            default:
                cell.accessoryType = .none
                break
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = Sections(rawValue: section) {
            if sections != .signOut {
                return NSLocalizedString(sections.description(), comment: "")
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            case .signOut:
                FirebaseService.shared.signOut()
                
//            case .deleteAccount:
//                FirebaseService.shared.deleteCurrentUser()
                
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
        signOut,
        max
    }
    
    enum AccountRow: Int {
        case userInfo = 0,
        groupInfo,
        max
    }
    
    enum AboutThisApp: Int {
        case help = 0,
        privacyPolicy,
        max
    }
}
