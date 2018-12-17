//
//  EditCustomMarketItemsViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/11/04.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

class EditCustomMarketItemsViewController: UITableViewController {

    var items = [[Harvest]]()
    var indicator: UIView?
    var delegate: UpdateCustomMarketItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "editCustomItem".localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDone))
        indicator = UIViewController.topIndicatorStart()
        FirebaseService.shared.observeCustomMarketItem { (items) in
            self.items = items
            self.tableView.reloadData()
            UIViewController.topIndicatorStop(view: self.indicator)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCustomMarketCell", for: indexPath)

        // Configure the cell...
        let harvest = items[indexPath.section][indexPath.row]
        cell.textLabel?.text = harvest.name.foodName
        
        cell.imageView?.image = UIImage(named: "cart")?.resize(size: CGSize(width: self.tableView.rowHeight, height: self.tableView.rowHeight))
        cell.imageView?.contentMode = .scaleAspectFit
        if harvest.imageUrl.isEmpty {
            cell.imageView?.image = UIImage(named: "baseline_help_black_48pt")!.withRenderingMode(.alwaysOriginal)
        } else {
            cell.imageView?.setImageByAlamofire(with: URL(string: harvest.imageUrl)!)
        }

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            indicator = UIViewController.topIndicatorStart()
            let harvest = items[indexPath.section][indexPath.row]
            FirebaseService.shared.removeMarketItem(harvest: harvest)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }    
    }

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
    
    @objc func tapDone() {
        delegate?.updatedItem()
        FirebaseService.shared.removeCustomMarketItemObsever()
    }
}
