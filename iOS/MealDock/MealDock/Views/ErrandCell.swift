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
    let checkImage = UIImageView(image: UIImage(named: "outline_check_black_36pt"))
    var label: UILabel!
    var checkImageBackgroundView: UIView!
    var checked = false {
        didSet {
            checkImageBackgroundView.isHidden = !checked
        }
    }

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
        
        checkImageBackgroundView = UIView(frame: frame)
        checkImageBackgroundView.backgroundColor = .darkGray
        checkImageBackgroundView.alpha = 0.8
        addSubview(checkImageBackgroundView)
        checkImageBackgroundView.autoPinEdgesToSuperviewEdges()
        checkImageBackgroundView.isHidden = true
        
        checkImage.contentMode = .scaleAspectFit
        checkImageBackgroundView.addSubview(checkImage)
        checkImage.autoCenterInSuperview()
    }

}
