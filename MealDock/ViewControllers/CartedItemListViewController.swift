//
//  CartedItemListViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

class CartedItemListViewController: MealDockListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("cartedFoods", comment: "")

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTapped))
        
        activateFab(fab: fab, target: self, image: UIImage(named: "freezer")!, selector: #selector(onFabTapped))
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @objc func onAddTapped() {
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
}
