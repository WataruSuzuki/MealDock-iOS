//
//  InFridgeListViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/08/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

class InFridgeListViewController: MealDockListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("inFridgeFoods", comment: "")
        activateFab(fab: fab, target: self, image: UIImage(named: "packed_food")!, selector: #selector(onFabTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseService.shared.observeInFridgeHarvest { (items) in
            self.harvests = items
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let customCell = cell as? StrikethroughTableViewCell {
            customCell.stepperMode = .decremental
            let harvest = harvests[indexPath.section][indexPath.row]
            customCell.stepperValue = harvest.count
            updateCheckedItems(value: harvest.count, harvest: harvest)
        }
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @objc override func onFabTapped() {
        let sb = UIStoryboard(name: "InFridgeList", bundle: Bundle.main)
        if let viewController = sb.instantiateViewController(withIdentifier: String(describing: EditDishViewController.self)) as? EditDishViewController {
            viewController.checkedItems = [Harvest](checkedItems.values)
            presentBottomSheet(viewController: viewController)
        }
        super.onFabTapped()
    }
    
}
