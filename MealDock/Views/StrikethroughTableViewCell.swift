//
//  StrikethroughTableViewCell.swift
//  MealDock
//
//  Created by 鈴木航 on 2018/10/04.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import TinyConstraints
import MaterialComponents.MDCPalettes

class StrikethroughTableViewCell: UITableViewCell {

    let stepper = UIStepper(frame: .zero)
    var stepperMode = StepperMode.incremental
    var stepperValue = 0 {
        didSet {
            stepper.value = Double(stepperValue)
            updateCount(value: stepperValue)
            switch stepperMode {
            case .incremental:
                updateStrikethrough(isStrikethrough: stepperValue > 0)
            case .decremental:
                updateStrikethrough(isStrikethrough: decrementValue > stepperValue)
                stepper.minimumValue = Double(stepperValue)
                stepper.maximumValue = Double(stepperValue * 2)
            }
        }
    }
    var decrementValue = 0
    var stepperValueChanged: ((Int)->Void)?
    let countLabel = UILabel(frame: .zero)
    let decrementCountLabel = UILabel(frame: .zero)
    let arrowLabel = UILabel(frame: .zero)

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
        updateCount(value: value)
        switch stepperMode {
        case .incremental:
            stepperValueChanged?(value)
            updateStrikethrough(isStrikethrough: value > 0)
        case.decremental:
            stepperValueChanged?(decrementValue)
            updateStrikethrough(isStrikethrough: value > stepperValue)
        }
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
        switch stepperMode {
        case .incremental:
            countLabel.text = value.description
            countLabel.isHidden = value == 0
            decrementCountLabel.isHidden = true
        case .decremental:
            countLabel.text = stepperValue.description
            decrementValue = value - stepperValue
            let remain = stepperValue - decrementValue
            decrementCountLabel.text = "\(remain)"
            decrementCountLabel.isHidden = remain == stepperValue
            break
        }
        arrowLabel.isHidden = decrementCountLabel.isHidden
    }
    
    private func setupCountLabel() {
        if let imageView = imageView {
            addSubview(countLabel)
            addSubview(arrowLabel)
            addSubview(decrementCountLabel)
            
            countLabel.textAlignment = .center
            countLabel.textColor = .white
            countLabel.backgroundColor = MDCPalette.orange.tint500
            countLabel.layer.cornerRadius = 10
            countLabel.clipsToBounds = true
            
            arrowLabel.textAlignment = .center
            arrowLabel.text = "➡️"
            
            decrementCountLabel.textAlignment = .center
            decrementCountLabel.textColor = .white
            decrementCountLabel.backgroundColor = MDCPalette.deepOrange.tint500
            decrementCountLabel.layer.cornerRadius = 10
            decrementCountLabel.clipsToBounds = true
            
            countLabel.aspectRatio(1.0)
            countLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
            countLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 2)
            
            arrowLabel.autoPinEdge(.leading, to: .trailing, of: countLabel, withOffset: 10)
            arrowLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 2)
            
            decrementCountLabel.aspectRatio(1.0)
            decrementCountLabel.autoPinEdge(.leading, to: .trailing, of: arrowLabel, withOffset: 10)
            decrementCountLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 2)
        }
    }
    
    enum StepperMode {
        case incremental, decremental
    }
}
