//
//  TextFieldCell.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/07.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections

class TextFieldCell: MDCCollectionViewCell {
    static let reuseIdentifier = String(describing: self)
    
    let textField = MDCTextField(frame: .zero)
    let multiLineField = MDCMultilineTextField(frame: .zero)
    var inputController: MDCTextInputController?
}
