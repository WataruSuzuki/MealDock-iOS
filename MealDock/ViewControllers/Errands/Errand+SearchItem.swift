//
//  Errand+SearcIhtem.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/12/19.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

protocol SearchMarketItemViewDelegate {
    func didSelect(harvest: Harvest, indexPath: IndexPath)
}

extension ErrandPagingViewController : SearchMarketItemViewDelegate {
    
    func didSelect(harvest: Harvest, indexPath: IndexPath) {
        let controllers = pagingViewController.viewControllers as! [ErrandViewController]
        controllers[indexPath.section].selectedItems.updateValue(harvest, forKey: harvest.name)
        controllers[indexPath.section].collectionView?.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
}
