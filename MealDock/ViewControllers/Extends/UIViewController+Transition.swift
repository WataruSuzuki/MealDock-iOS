//
//  UIViewController+Transition.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/24.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet
import MaterialComponents.MaterialAppBar

extension UIViewController {
    @objc func tapDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func presentBottomSheet(viewController: UICollectionViewController) {
        // Initialize the bottom sheet with the view controller just created
        let container = MDCAppBarContainerViewController.init(contentViewController: viewController)
        container.preferredContentSize = CGSize(width: 500, height: self.view.frame.height / 2)
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
