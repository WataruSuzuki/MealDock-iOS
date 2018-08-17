//
//  GooglePhoto+Access.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import Alamofire

extension GooglePhotosService {
    
    func getMediaItemUrl(MEDIA_ITEM_ID: String, result:((String, Error?) -> Void)?) {
        let endpoint = "https://photoslibrary.googleapis.com/v1/mediaItems/" + MEDIA_ITEM_ID
        freshToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            Alamofire.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.result.error == nil, let value = dataResponse.result.value else {
                        print(dataResponse.result.error!)
                        return
                    }
                    debugPrint(value)
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        let media = try JSONDecoder().decode(GooglePhotosMediaItem.self, from: jsonData)
                        
                        result?(media.baseUrl! + "=w\(self.mediaItemSize)-h\(self.mediaItemSize)" , nil)
                    } catch let error {
                        print(error)
                        result?("", error)
                    }
                })
        }) { (error) in
            print(error)
        }
    }
}
