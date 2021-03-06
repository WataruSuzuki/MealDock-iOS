//
//  InFridgeListViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/08/15.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

class InFridgeListViewController: MealDockListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "inFridgeFoods".localized
        activateFab(fab: fab, target: self, image: UIImage(named: "dish")!, tap: #selector(onFabTapped), longTap: #selector(onFabLongPressed))
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
            customCell.decrementMaxValue = harvest.count
            customCell.stepperValueChanged = { (value) in
                var decrementalHarvest = Harvest(name: harvest.name, section: harvest.section, imageUrl: harvest.imageUrl)
                decrementalHarvest.count = value
                self.updateCheckedItems(harvest: decrementalHarvest)
            }
            if let item = checkedItems[harvest.name] {
                customCell.stepperValue = item.count
            } else {
                customCell.stepperValue = 0
            }
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

    override func refresh() {
        FirebaseService.shared.loadInFridgeHarvest(success: { (harvests) in
            self.harvests = harvests
            self.tableView.reloadData()
            super.refresh()
        })
    }
    
    @objc override func onFabTapped() {
        let sb = UIStoryboard(name: "InFridgeList", bundle: Bundle.main)
        if let viewController = sb.instantiateViewController(withIdentifier: String(describing: EditDishViewController.self)) as? EditDishViewController {
            viewController.checkedItems = [Harvest](checkedItems.values)
            
            #if canImport(FloatingPanel)
                let navigation = UINavigationController(rootViewController: viewController)
                floatingPanel.set(contentViewController: navigation)
                floatingPanel.track(scrollView: viewController.collectionView!)
                floatingPanel.surfaceView.cornerRadius = 25.0
                floatingPanel.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
                self.present(floatingPanel, animated: true, completion: nil)
            #else //canImport(FloatingPanel)
                presentBottomSheet(viewController: viewController)
            #endif //canImport(FloatingPanel)
        }
        super.onFabTapped()
    }
    
    override func onTapPlane() {
        if let deepLink = FirebaseService.shared.createDeepLink(extra: FirebaseService.DeepLinkExtra.inFridgeFoods.rawValue) {
            let message = "msg_link_in_fridge_foods".localized + "\n\n"
            let activity = UIViewController.getActivityViewController(items: [message, deepLink])
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                activity.popoverPresentationController?.sourceView = view
                activity.popoverPresentationController?.sourceRect = view.frame
            }
            
            present(activity, animated: true, completion: nil)
        }
        super.onTapPlane()
    }
    
    override func onTapDelete() {
        let items = [Harvest](checkedItems.values)
        FirebaseService.shared.removeFromFridge(harvests: items)
        
        super.onTapDelete()
    }
}
