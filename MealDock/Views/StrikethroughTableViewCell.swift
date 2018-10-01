//
//  StrikethroughTableViewCell.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/04.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import TinyConstraints

class StrikethroughTableViewCell: UITableViewCell {

    let stepper = UIStepper(frame: .zero)
    var stepperValue = 0 {
        didSet {
            stepper.value = Double(stepperValue)
            updateCount(value: stepperValue)
        }
    }
    var stepperValueChanged: ((Int)->Void)?
    let countLabel = UILabel(frame: .zero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        setupCountLabel()
        
        stepper.minimumValue = 0
        stepper.maximumValue = 100
        stepper.stepValue = 1
        stepper.addTarget(self, action: #selector(changeStepper), for: .valueChanged)
        accessoryView = stepper
    }

    @objc private func changeStepper(sender: UIStepper) {
        let value = Int(sender.value)
        stepperValueChanged?(value)
        updateStrikethrough(isStrikethrough: value > 0)
        updateCount(value: value)
    }
    
    private func updateStrikethrough(isStrikethrough: Bool) {
        if isStrikethrough {
            if let originalStr = self.textLabel?.text {
                let attrStr = NSMutableAttributedString(string: originalStr)
                attrStr.addAttribute(.strikethroughStyle, value: 3, range: NSRange(location: 0, length: originalStr.count))
                self.textLabel?.attributedText = attrStr
            }
        } else {
            let string = self.textLabel?.attributedText?.string
            self.textLabel?.attributedText = nil
            self.textLabel?.text = string
        }
    }

    func updateCount(value: Int) {
        if countLabel.superview == nil {
            setupCountLabel()
        }
        countLabel.text = value.description
        countLabel.isHidden = value == 0
    }
    
    private func setupCountLabel() {
        if let imageView = imageView {
            addSubview(countLabel)
            countLabel.textAlignment = .center
            countLabel.textColor = .white
            countLabel.backgroundColor = .red
            countLabel.layer.cornerRadius = 10
            countLabel.clipsToBounds = true
            
            countLabel.aspectRatio(1.0)
            countLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
            countLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        }
    }
}
