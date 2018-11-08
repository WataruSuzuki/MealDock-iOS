//
//  UIImageView+Alamofire.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/09/24.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import Foundation
import AlamofireImage

extension UIImageView {
    
    func setImageByAlamofire(with url: URL) {
        setImageByAlamofire(with: url, cacheKey: url.absoluteString)
    }
    
    func setImageByAlamofire(with url: URL, cacheKey: String) {
        if let cachedImage = ImageCacheService.shared.imageCache.image(withIdentifier: cacheKey) {
            self.image = cachedImage
        } else {
            af_setImage(withURL: url) { [weak self] response in
                switch response.result {
                case .success(let image):
                    ImageCacheService.shared.imageCache.add(image, withIdentifier: cacheKey)
                    self?.image = image
                    
                case .failure(_):
                    // error handling
                    break
                }
            }
        }
    }
}
