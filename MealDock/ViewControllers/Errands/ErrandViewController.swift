//
//  ErrandViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/17.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import Alamofire
import MaterialComponents.MaterialCollections

class ErrandViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout,
    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    let reuseIdentifier = "ErrandCell"
    var items: [Harvest]!
    var selectedItems = [String : Harvest]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(ErrandCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerCustomCell(String(describing: ErrandCell.self))

        // Do any additional setup after loading the view.
        self.collectionView!.emptyDataSetSource = self
        self.collectionView!.emptyDataSetDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return errandCollection(collectionView, cellForItemAt: indexPath, item: items[indexPath.row])
    }
    
    func errandCollection(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: Harvest?) -> ErrandCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ErrandCell
        guard let item = item else { return cell }

        // Configure the cell
        cell.label.text = NSLocalizedString(item.name, tableName: "MarketItems", comment: "")
        if let url = URL(string: item.imageUrl) {
            cell.itemImage.setImageByAlamofire(with: url)
        } else {
            cell.itemImage.image = UIImage(named: "baseline_help_black_48pt")!.withRenderingMode(.alwaysOriginal)
        }
        cell.isChecked = selectedItems.contains(where: { (selected) -> Bool in
            return selected.key == item.name
        })

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ErrandCell
        cell.isChecked = !cell.isChecked
        if cell.isChecked {
            selectedItems.updateValue(items[indexPath.row], forKey: items[indexPath.row].name)
        } else {
            selectedItems.removeValue(forKey: items[indexPath.row].name)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.getCellSize(baseCellNum: 4)
    }

    // MARK: DZNEmptyDataSetSource

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100.0
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Items")
    }
}
