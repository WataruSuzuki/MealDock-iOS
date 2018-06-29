//
//  CartedItemListViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet

class CartedItemListViewController: MealDockListViewController {
    var harvests = [[Harvest]]()
    let shapeScheme = MDCShapeScheme()
    let customCellIdentifier = String(describing: StrikethroughTableViewCell.self)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerCustomCell(customCellIdentifier)
//        self.collectionView!.register(MDCCollectionViewTextCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: UICollectionElementKindSectionHeader)

        // Do any additional setup after loading the view.
//        styler.cellStyle = .card
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTapped))
        //addTargetToFab(target: self, action: #selector(onAddFabTapped))
        FirebaseService.shared.observeHarvest { (harvests) in
            self.harvests = harvests
            self.tableView.reloadData()
        }
        
        activateFab(target: self, image: UIImage(named: "freezer")!, selector: #selector(onFabTapped))
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

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return harvests.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return harvests[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customCellIdentifier, for: indexPath) as! StrikethroughTableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = harvests[indexPath.section][indexPath.row].name
        
        cell.imageView?.image = UIImage(named: "harvest")?.resize(size: CGSize(width: self.tableView.rowHeight, height: self.tableView.rowHeight))
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.setImageByAlamofire(with: URL(string: harvests[indexPath.section][indexPath.row].imageUrl)!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if 0 < harvests[section].count {
            if let harvestSection = Harvest.Section(rawValue: section) {
                return harvestSection.emoji()
            }
        }
        return nil
    }
    
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

//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! MDCCollectionViewTextCell
//        if kind == UICollectionElementKindSectionHeader {
//            if let section = Harvest.Section(rawValue: indexPath.section) {
//                view.textLabel?.text = NSLocalizedString(section.toString(), comment: "")
//            }
//        }
//        return view
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        if 0 == collectionView.numberOfItems(inSection: section) {
//            return CGSize(width: 0, height: 0)
//        } else {
//            return CGSize(width: collectionView.bounds.size.width, height: MDCCellDefaultOneLineHeight)
//        }
//    }

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
    
    @objc func onFabTapped() {
        let items = [Harvest](checkedItems.values)
        for item in items {
            FirebaseService.shared.addToFridge(harvest: item)
        }
    }
    
    func showViaBottomSheet(viewController: UICollectionViewController) {
        // Initialize the bottom sheet with the view controller just created
        let container = AppBarContainerViewController.init(contentViewController: viewController)
        container.preferredContentSize = CGSize(width: 500, height: 200)
        container.appBarViewController.headerView.trackingScrollView = viewController.collectionView
        container.isTopLayoutGuideAdjustmentEnabled = true
        MDCAppBarColorThemer.applyColorScheme(MDCSemanticColorScheme(), to: container.appBarViewController)
        
        let bottomSheet = MDCBottomSheetController(contentViewController: container)
        MDCBottomSheetControllerShapeThemer.applyShapeScheme(MDCShapeScheme(), to: bottomSheet)
        bottomSheet.trackingScrollView = viewController.collectionView;
        // Present the bottom sheet
        present(bottomSheet, animated: true, completion: nil)
    }
}
