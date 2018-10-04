//
//  TextFieldCell.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/07.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections

class TextFieldCell: MDCCollectionViewCell {
    let textField = MDCTextField(frame: .zero)
    let multiLineField = MDCMultilineTextField(frame: .zero)
    var inputController: MDCTextInputController?
}
