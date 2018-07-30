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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)

        // Configure the cell...
        if let section = Sections(rawValue: indexPath.section) {
            cell.textLabel?.text = NSLocalizedString(section.toString(), comment: "")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let section = Sections(rawValue: indexPath.section) {
            switch section {
            case .accountInfo:
                //FirebaseService.shared.printUserInfo()
                break
            case .groupInfo:
                performSegue(withIdentifier: String(describing: GroupInfoViewController.self), sender: self)
                GroupInfoViewController.description()
            case .signOut:
                FirebaseService.shared.signOut()
                
            case .deleteAccount:
                FirebaseService.shared.deleteCurrentUser()
                
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
        case accountInfo = 0,
        groupInfo,
        help,
        privacyPolicy,
        signOut,
        deleteAccount,
        max
        
        func toString() -> String {
            return String(describing: self)
        }
    }
}
