//
//  DishCardCollectionCell.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/08.
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
            checkImageView.image = (isChecked ? checkImage : uncheckImage)
        }
    }
    var selectingMode = false {
        didSet {
            checkmarkBackgroundView.isHidden = !selectingMode
        }
    }
    private let checkImageView = UIImageView(frame: .zero)
    private let checkImage = UIImage(named: "baseline_check_box_black_36pt")!
    private let uncheckImage = UIImage(named: "baseline_check_box_outline_blank_black_36pt")!
    private var checkmarkBackgroundView: UIView!

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
        checkmarkBackgroundView.backgroundColor = .white
        checkmarkBackgroundView.alpha = 0.8
        self.contentView.addSubview(checkmarkBackgroundView)
        checkmarkBackgroundView.autoPinEdgesToSuperviewEdges()
        checkmarkBackgroundView.isHidden = true
        
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.image = uncheckImage
        checkmarkBackgroundView.addSubview(checkImageView)
        checkImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        checkImageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
    }
}
