//
//  StrikethroughTableViewCell.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/04.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit

class StrikethroughTableViewCell: UITableViewCell {

    var isChecked = false {
        didSet {
            if isChecked {
                if let originalStr = self.textLabel?.text {
                    let attrStr = NSMutableAttributedString(string: originalStr)
                    attrStr.addAttribute(.strikethroughStyle, value: 3, range: NSRange(location: 0, length: originalStr.count))
                    self.textLabel?.attributedText = attrStr
                }
                self.accessoryType = .checkmark
            } else {
                let string = self.textLabel?.attributedText?.string
                self.textLabel?.attributedText = nil
                self.textLabel?.text = string
                self.accessoryType = .none
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
