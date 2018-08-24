//
//  HarvestListViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet

class HarvestListViewController: MealDockBaseCollectionViewController,
    MealDockAdder
{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        styler.cellStyle = .card
        addTargetToFab(target: self, action: #selector(onAddFabTapped))
        FirebaseService.shared.observeHarvest { (snapshot) in
            
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

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    @objc override func onAddFabTapped() {
        let sb = UIStoryboard(name: "HarvestList", bundle: Bundle.main)
        if let viewController = sb.instantiateViewController(withIdentifier: String(describing: ErrandViewController.self)) as? ErrandViewController {
            // Initialize the bottom sheet with the view controller just created
            let container = AppBarContainerViewController.init(contentViewController: viewController)
            container.preferredContentSize = CGSize(width: 500, height: 200)
            container.appBarViewController.headerView.trackingScrollView =
                viewController.collectionView
            container.isTopLayoutGuideAdjustmentEnabled = true
            
            let bottomSheet = MDCBottomSheetController(contentViewController: container)
            bottomSheet.trackingScrollView = viewController.collectionView;
            // Present the bottom sheet
            present(bottomSheet, animated: true, completion: nil)
        }
    }
}
