//
//  PickerCell.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections

class PickerCell: MDCCollectionViewCell,
    UIPickerViewDelegate, UIPickerViewDataSource
{
    
    let picker = UIPickerView(frame: .zero)
    var dataList: [String]! {
        didSet {
            picker.delegate = self
        }
    }
    var didSelect: ((Int)->Void)?
    
    func autoPinPicker() {
        picker.autoPinEdge(toSuperviewEdge: .top, withInset: MDCCellDefaultOneLineHeight)
        picker.autoPinEdge(toSuperviewEdge: .leading)
        picker.autoPinEdge(toSuperviewEdge: .trailing)
        picker.autoSetDimension(.height, toSize: 200)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelect?(row)
    }
}
