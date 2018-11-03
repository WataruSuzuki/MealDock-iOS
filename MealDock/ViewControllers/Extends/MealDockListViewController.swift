//
//  MealDockListViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/02.
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
        
        let colorScheme = MDCSemanticColorScheme()
        colorScheme.primaryColor = MDCPalette.lightBlue.tint500
        colorScheme.primaryColorVariant = MDCPalette.lightBlue.tint400
        colorScheme.secondaryColor = colorScheme.primaryColor
        
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if 0 < harvests[section].count {
            if let user = FirebaseService.shared.currentUser, !user.isPurchased {
                return PurchaseService.shared.bannerView(unitId: "ca-app-pub-3165756184642596/4608493613", rootViewController: self)
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if 0 < harvests[section].count {
            if let user = FirebaseService.shared.currentUser, !user.isPurchased {
                return 50
            }
        }
        return 0
    }
    
    private func tableViewCustomCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, harvests: [[Harvest]]) -> StrikethroughTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customCellIdentifier, for: indexPath) as! StrikethroughTableViewCell
        
        // Configure the cell...
        cell.selectionStyle = .none
        
        let harvest = harvests[indexPath.section][indexPath.row]
        cell.textLabel?.text = NSLocalizedString(harvest.name, tableName: "MarketItems", comment: "")
        
        cell.imageView?.image = UIImage(named: "harvest")?.resize(size: CGSize(width: self.tableView.rowHeight, height: self.tableView.rowHeight))
        cell.imageView?.contentMode = .scaleAspectFit
        if !harvest.imageUrl.isEmpty {
            cell.imageView?.setImageByAlamofire(with: URL(string: harvest.imageUrl)!)
        }
                
        return cell
    }
    
    func updateCheckedItems(harvest: Harvest) {
        if harvest.count > 0 {
            checkedItems.updateValue(harvest, forKey: harvest.name)
        } else {
            checkedItems.removeValue(forKey: harvest.name)
        }
        fab.isHidden = 0 == checkedItems.count
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
    
    // MARK: DZNEmptyDataSetSource

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100.0
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("no_foods", comment: ""))
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("msg_add_foods", comment: ""))
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        if let _ =  FirebaseService.shared.currentUser {
            return NSAttributedString()
        } else {
            return NSAttributedString(string: NSLocalizedString("signIn", comment: ""))
        }
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        guard FirebaseService.shared.currentUser == nil else { return }
        FirebaseService.shared.requestAuthUI()
    }

    func onFabTapped() {
        self.fab.isHidden = true
        checkedItems.removeAll()
    }
}
