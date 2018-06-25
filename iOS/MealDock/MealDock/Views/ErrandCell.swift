//
//  ErrandCell.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/24.
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
        addSubview(label)
        label.centerYToSuperview()
        label.isHidden = true
        
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
