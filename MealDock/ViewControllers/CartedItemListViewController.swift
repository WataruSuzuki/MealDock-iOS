//
//  CartedItemListViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

class CartedItemListViewController: MealDockListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "cartedFoods".localized

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTapped))
        
        activateFab(fab: fab, target: self, image: UIImage(named: "freezer")!, tap: #selector(onFabTapped), longTap: #selector(onFabLongPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseService.shared.observeCartedHarvest { (harvests) in
            self.harvests = harvests
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
            var harvest = harvests[indexPath.section][indexPath.row]
            customCell.stepperValueChanged = { (value) in
                harvest.count = value
                self.updateCheckedItems(harvest: harvest)
            }
            if let item = checkedItems[harvest.name] {
                customCell.stepperValue = item.count
            } else {
                customCell.stepperValue = harvest.count
            }
        }

        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @objc func onAddTapped() {
        guard let user = FirebaseService.shared.currentUser else {
            OptionalError.alertErrorMessage(message: "(=；人；=)", actions: nil)
            return
        }
        if user.isPurchased || PurchaseService.shared.hasTicket() {
            showErrand()
        } else {
            PurchaseService.shared.showReward(rootViewController: self)
        }
    }
    
    func showErrand()  {
        FirebaseService.shared.loadMarketItems(success: { (items) in
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "Errand", bundle: Bundle.main)
                if let viewController = sb.instantiateViewController(withIdentifier: String(describing: ErrandPagingViewController.self)) as? ErrandPagingViewController {
                    viewController.items = items
                    let navigation = UINavigationController.init(rootViewController: viewController)
                    self.present(navigation, animated: true, completion: nil)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc override func onFabTapped() {
        let items = [Harvest](checkedItems.values)
        FirebaseService.shared.addToFridge(harvests: items)
        
        super.onFabTapped()
    }
    
    override func onTapPlane() {
        if let deepLink = FirebaseService.shared.createDeepLink(extra: FirebaseService.DeepLinkExtra.cartedFoods.rawValue) {
            let message = "msg_link_carted_foods".localized + "\n\n"
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
        FirebaseService.shared.removeFromCart(harvests: items)
        
        super.onTapDelete()
    }
}
