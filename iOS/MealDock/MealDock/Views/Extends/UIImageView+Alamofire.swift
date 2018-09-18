//
//  UIImageView+Alamofire.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/09/24.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation
import AlamofireImage

extension UIImageView {
    
    func setImageByAlamofire(with url: URL) {
        
        af_setImage(withURL: url) { [weak self] response in
            switch response.result {
            case .success(let image):
                self?.image = image
                
            case .failure(_):
                // error handling
                break
            }
            
        }
    }
}
