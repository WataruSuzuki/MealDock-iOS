//
//  DetailDishViewController.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/28.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
//import MaterialComponents.MaterialButtons_ButtonThemer
import MaterialComponents.MaterialCards_CardThemer
import TinyConstraints

class DetailDishViewController: UIViewController {

    var dish: Dish!
    var loadedImage: UIImage?
    
    let card = MDCCard()
    let imageView = CardImageView(image: UIImage(named: "baseline_help_black_48pt")!)
//    let button = MDCButton(frame: .zero)
    let descriptionTextView = UITextView(frame: .zero)
    
    var colorScheme = MDCSemanticColorScheme()
    var shapeScheme = MDCShapeScheme()
    var typographyScheme = MDCTypographyScheme()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = dish.title
        view.addSubview(card)
        card.addSubview(imageView)
        card.addSubview(descriptionTextView)
//        card.addSubview(button)
        
//        let buttonScheme = MDCButtonScheme();
//        buttonScheme.colorScheme = colorScheme
//        buttonScheme.typographyScheme = typographyScheme
//        MDCTextButtonThemer.applyScheme(buttonScheme, to: button)
        
        let cardScheme = MDCCardScheme();
        cardScheme.colorScheme = colorScheme
        cardScheme.shapeScheme = shapeScheme
        MDCCardThemer.applyScheme(cardScheme, to: card)
        card.isInteractable = false
        
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "Missing Dish"
        imageView.contentMode = .scaleAspectFit
        if let image = loadedImage {
            imageView.image = image
        } else {
            GooglePhotosService.shared.getMediaItemUrl(MEDIA_ITEM_ID: dish.imagePath) { (url, error) in
                guard error == nil else { return }
                self.imageView.setImageByAlamofire(with: URL(string: url)!)
            }
        }
        imageView.backgroundColor = .gray
        
        descriptionTextView.text = dish.description
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        card.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10))
        
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        imageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        imageView.aspectRatio(1.0)
        
        descriptionTextView.sizeToFit()
        descriptionTextView.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 10)
        descriptionTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        descriptionTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        descriptionTextView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
    }
}

extension DetailDishViewController {
    
//    class func catalogMetadata() -> [String: Any] {
//        return [
//            "breadcrumbs": ["Cards", "Card (Swift)"],
//            "description": "Cards contain content and actions about a single subject.",
//            "primaryDemo": true,
//            "presentable": true,
//        ]
//    }
}

class CardImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.curveImageToCorners()
    }
    
    func curveImageToCorners() {
        // The main image from the xib is taken from: https://unsplash.com/photos/wMzx2nBdeng
        // License details: https://unsplash.com/license
        if let card = self.superview as? MDCCard,
            let shapedShadowLayer = card.layer as? MDCShapedShadowLayer {
            self.layer.mask = shapedShadowLayer.shapeLayer
        }
    }

}
