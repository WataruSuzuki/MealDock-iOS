//
//  GooglePhoto+Upload.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import Alamofire

extension GooglePhotosService {
    
    func uploadDishPhoto(image: UIImage?, uploadedMediaId:((String) -> Void)?, failure :((Error?) -> ())?) {
        guard let image = image else {
            uploadedMediaId?("")
            return
        }
        let endpoint = "https://photoslibrary.googleapis.com/v1/uploads"
        let timeIntervalStr = String(describing: Date().timeIntervalSince1970)
        freshExecuterToken(token: { (token) in
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-type": "application/octet-stream",
                "X-Goog-Upload-File-Name": "\(timeIntervalStr).jpg",
                "X-Goog-Upload-Protocol": "raw"
            ]
            guard let data = UIImagePNGRepresentation(image) else {
                let optionalError = OptionalError(with: OptionalError.Cause.failedToGetPhotoData, userInfo: nil)
                failure?(optionalError)
                return
            }
            Alamofire.upload(data, to: URL(string: endpoint)!, method: HTTPMethod.post, headers: headers)
                .responseString(completionHandler: { (response) in
                    debugPrint("(・∀・)uploadToken: \(response)")
                    guard let uploadToken = response.value else {
                        let optionalError = OptionalError(with: OptionalError.Cause.failedToGetToken, userInfo: nil)
                        failure?(optionalError)
                        return
                    }
                    self.creatingMediaItem(uploadToken: uploadToken, result: { (id, error) in
                        if let error = error {
                            print(error)
                            failure?(error)
                        } else {
                            uploadedMediaId?(id)
                        }
                    })
                })
        }) { (error) in
            print(error)
            failure?(error)
        }
    }
    
    private func creatingMediaItem(uploadToken:String, result:((String, Error?) -> Void)?) {
        let endpoint = "https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate"
        freshExecuterToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            guard let albumId = self.albumId else {
                let optionalError = OptionalError(with: OptionalError.Cause.failedToCreatePhotoSaveSpace, userInfo: nil)
                result?("", optionalError)
                return
            }
            let param = [
                "albumId": "\(albumId)",
                "newMediaItems": [
                    "description": "Created by Meal Dock",
                    "simpleMediaItem" : ["uploadToken": uploadToken]
                ]
                ] as [String : Any]
            Alamofire.request(endpoint, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .responseJSON(completionHandler: { (data) in
                    guard data.result.error == nil, let value = data.result.value as? [String : [Any]] else {
                        print(data.result.error!)
                        result?("", data.result.error!)
                        return
                    }
                    debugPrint(value)
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        let responseJson = try JSONDecoder().decode(GooglePhotosNewMediaItemResultResponse.self, from: jsonData)
                        
                        result?(responseJson.newMediaItemResults[0].mediaItem.id, nil)
                    } catch let error {
                        print(error)
                        result?("", error)
                    }
                })
        }) { (error) in
            result?("", error)
        }
    }
    
}
