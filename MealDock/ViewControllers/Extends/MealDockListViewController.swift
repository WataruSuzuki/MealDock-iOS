//
//  MealDockListViewController.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/02.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections
import MaterialComponents.MaterialButtons_ColorThemer
import TinyConstraints

class MealDockListViewController: UITableViewController,
    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    let fab = MDCFloatingButton()
    let customCellIdentifier = String(describing: StrikethroughTableViewCell.self)
    var harvests = [[Harvest]]()
    var checkedItems = [String : Harvest]()
    let colorScheme = MDCSemanticColorScheme()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(fab)
        fab.isHidden = true
        
        self.tableView.registerCustomCell(customCellIdentifier)
        self.tableView.rowHeight = CGFloat(integerLiteral: 66)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        // A little trick for removing the cell separators
        self.tableView.tableFooterView = UIView()
        
        MDCFloatingButtonColorThemer.applySemanticColorScheme(colorScheme, to: fab)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            self.layout(fab: self.fab)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return harvests.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return harvests[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableViewCustomCell(tableView, cellForRowAt: indexPath, harvests: harvests)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if 0 < harvests[section].count {
            if let harvestSection = Harvest.Section(rawValue: section) {
                return harvestSection.emoji()
            }
        }
        return nil
    }
    
    fileprivate func tableViewCustomCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, harvests: [[Harvest]]) -> StrikethroughTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customCellIdentifier, for: indexPath) as! StrikethroughTableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = harvests[indexPath.section][indexPath.row].name
        
        cell.imageView?.image = UIImage(named: "harvest")?.resize(size: CGSize(width: self.tableView.rowHeight, height: self.tableView.rowHeight))
        cell.imageView?.contentMode = .scaleAspectFit
        if !harvests[indexPath.section][indexPath.row].imageUrl.isEmpty {
            cell.imageView?.setImageByAlamofire(with: URL(string: harvests[indexPath.section][indexPath.row].imageUrl)!)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! StrikethroughTableViewCell
        let harvest = harvests[indexPath.section][indexPath.row]
        cell.isChecked = !cell.isChecked
        if cell.isChecked {
            checkedItems.updateValue(harvest, forKey: harvest.name)
        } else {
            checkedItems.removeValue(forKey: harvest.name)
        }
        fab.isHidden = 0 == checkedItems.count
    }
    
    // MARK: DZNEmptyDataSetSource

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100.0
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Foods")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Let's start to add foods")
    }
}
