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
    
    let imageView = UIImageView(image: UIImage(named: "baseline_help_black_48pt"))
    var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
        
        label = UILabel(frame: frame)
        addSubview(label)
        label.centerYToSuperview()
        label.isHidden = true
    }

}
