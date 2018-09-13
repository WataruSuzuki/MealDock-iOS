//
//  UICollectionView+CustomNib.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/24.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension UICollectionView {
    func registerCustomCell(_ nibIdentifier: String) {
        let nib = UINib(nibName: nibIdentifier, bundle: nil)
        register(nib, forCellWithReuseIdentifier: nibIdentifier)
    }
}
