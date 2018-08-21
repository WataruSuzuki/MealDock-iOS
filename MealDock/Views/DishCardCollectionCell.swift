//
//  DishCardCollectionCell.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/08.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards_CardThemer
import MaterialComponents.MaterialTypographyScheme

class DishCardCollectionCell: MDCCardCollectionCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let shapedShadowLayer = self.layer as? MDCShapedShadowLayer {
            imageView.layer.mask = shapedShadowLayer.shapeLayer
        }
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var isChecked = false {
        didSet {
            checkmarkBackgroundView.isHidden = !isChecked
        }
    }
    fileprivate let checkmarkImage = UIImageView(image: UIImage(named: "outline_check_black_36pt"))
    fileprivate var checkmarkBackgroundView: UIView!

    func configure(title: String, imageName: String) {
        let bundle = Bundle(for: DishCardCollectionCell.self)
        
        self.imageView.image  = UIImage(named: imageName, in: bundle, compatibleWith: nil)
        self.titleLabel.text = title
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800), for: .vertical)
        
        addCheckmarks()
        addConstraints()
    }
    
    func apply(cardScheme: MDCCardScheme, typographyScheme: MDCTypographyScheme) {
        MDCCardThemer.applyScheme(cardScheme, toCardCell: self)
        self.titleLabel.font = typographyScheme.caption
    }
    
    private func addConstraints() {
        let views: [String: UIView] = ["image": self.imageView, "label": self.titleLabel]
        let metrics = ["margin": 4.0]
        self.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[image]|",
                options: [], metrics: metrics, views: views) +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[image]-(margin)-[label]-(margin)-|",
                    options: [], metrics: metrics, views: views) +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-(margin)-[label]|",
                    options: [], metrics: metrics, views: views)
        );
    }
    
    func addCheckmarks() {
        checkmarkBackgroundView = UIView(frame: frame)
        checkmarkBackgroundView.backgroundColor = .darkGray
        checkmarkBackgroundView.alpha = 0.8
        self.contentView.addSubview(checkmarkBackgroundView)
        checkmarkBackgroundView.autoPinEdgesToSuperviewEdges()
        checkmarkBackgroundView.isHidden = true
        
        checkmarkImage.contentMode = .scaleAspectFit
        checkmarkBackgroundView.addSubview(checkmarkImage)
        checkmarkImage.autoCenterInSuperview()
    }
}
