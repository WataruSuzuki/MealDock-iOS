//
//  ErrandCell.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/24.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import TinyConstraints

class ErrandCell: UICollectionViewCell {
    
    let itemImage = UIImageView(image: UIImage(named: "baseline_help_black_48pt"))
    var label: UILabel!
    var isChecked = false {
        didSet {
            checkmarkBackgroundView.isHidden = !isChecked
        }
    }
    fileprivate let checkmarkImage = UIImageView(image: UIImage(named: "outline_check_black_36pt"))
    fileprivate var checkmarkBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemImage.contentMode = .scaleAspectFit
        addSubview(itemImage)
        itemImage.autoPinEdgesToSuperviewEdges()
        
        label = UILabel(frame: frame)
        label.text = "???"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.backgroundColor = .black
        label.alpha = 0.8
        addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .bottom)
        label.autoPinEdge(toSuperviewEdge: .leading)
        label.autoPinEdge(toSuperviewEdge: .trailing)

        checkmarkBackgroundView = UIView(frame: frame)
        checkmarkBackgroundView.backgroundColor = .darkGray
        checkmarkBackgroundView.alpha = 0.8
        addSubview(checkmarkBackgroundView)
        checkmarkBackgroundView.autoPinEdgesToSuperviewEdges()
        checkmarkBackgroundView.isHidden = true
        
        checkmarkImage.contentMode = .scaleAspectFit
        checkmarkBackgroundView.addSubview(checkmarkImage)
        checkmarkImage.autoCenterInSuperview()
    }

}
