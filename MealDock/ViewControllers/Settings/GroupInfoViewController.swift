//
//  GroupInfoViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/14.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

class GroupInfoViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groupInfo = Sections(rawValue: section) {
            switch groupInfo {
            case .invitedMembers:
                return 1
                
            case .manageGroupStatus:
                return ManageStatus.max.rawValue
                
            default:
                break
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfoCell", for: indexPath)

        // Configure the cell...
        if let groupInfo = Sections(rawValue: indexPath.section) {
            switch groupInfo {
            case .invitedMembers:
                cell.textLabel?.text = "(=・∀・=)"
                
            case .manageGroupStatus:
                if let managing = ManageStatus(rawValue: indexPath.row) {
                    cell.textLabel?.text = NSLocalizedString(managing.description(), comment: "")
                }

            default:
                break
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let groupInfo = Sections(rawValue: section) {
            return NSLocalizedString(groupInfo.description(), comment: "")
        }
        return nil
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.invitedMembers.rawValue
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let groupInfo = Sections(rawValue: indexPath.section) {
            switch groupInfo {
            case .manageGroupStatus:
                FirebaseService.shared.addMyDockGroupMember(memberId: "test2", name: "hoge")
            default:
                break
            }
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

    enum Sections: Int {
        case invitedMembers = 0,
        manageGroupStatus,
        max
    }
    
    enum ManageStatus: Int {
        case joinToInvitation = 0,
        reaveFromInvitation,
        max
    }
}
