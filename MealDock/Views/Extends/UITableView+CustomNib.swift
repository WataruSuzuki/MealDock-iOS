//
//  UITableView+CustomNib.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/04.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation

extension UITableView {
    func registerCustomCell(_ nibIdentifier: String) {
        let nib = UINib(nibName: nibIdentifier, bundle: nil)
        register(nib, forCellReuseIdentifier: nibIdentifier)
    }
}
