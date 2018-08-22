//
//  UIView+Indicator.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/18.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialSnackbar

extension UIView {
    
    func startIndicator() -> UIView {
        let activityIndicator = MDCActivityIndicator()
        //let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.sizeToFit()
        addSubview(activityIndicator)
        
        activityIndicator.autoCenterInSuperview()
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    func stopIndicator(view: UIView) {
        if let indicator = view as? MDCActivityIndicator {
            //if let indicator = view as? UIActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
    
}
