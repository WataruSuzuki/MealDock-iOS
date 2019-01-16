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
        setImageByAlamofire(with: url, cacheKey: url.absoluteString, showIndicator: true)
    }
    
    func setImageByAlamofire(with url: URL, cacheKey: String) {
        setImageByAlamofire(with: url, cacheKey: cacheKey, showIndicator: false)
    }
    
    func setImageByAlamofire(with url: URL, cacheKey: String, showIndicator: Bool) {
        if let cachedImage = ImageCacheService.shared.imageCache.image(withIdentifier: cacheKey) {
            self.image = cachedImage
        } else {
            var indicator: UIView?
            if showIndicator {
                indicator = startIndicator()
            }
            af_setImage(withURL: url) { [weak self] response in
                self?.stopIndicator(view: indicator)
                switch response.result {
                case .success(let image):
                    if url == response.request?.url {
                        ImageCacheService.shared.imageCache.add(image, withIdentifier: cacheKey)
                        self?.image = image
                        return
                    }
                    fallthrough
                default:
                    // error handling
                    self?.image = UIImage(named: "baseline_help_black_48pt")!.withRenderingMode(.alwaysOriginal)
                }
            }
        }
    }
}
