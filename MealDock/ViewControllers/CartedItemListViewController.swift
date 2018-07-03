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

        self.title = NSLocalizedString("carted", comment: "")
//        self.collectionView!.register(MDCCollectionViewTextCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: UICollectionElementKindSectionHeader)

        // Do any additional setup after loading the view.
//        styler.cellStyle = .card
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTapped))
        //addTargetToFab(target: self, action: #selector(onAddFabTapped))
        FirebaseService.shared.observeCartedHarvest { (harvests) in
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
}
