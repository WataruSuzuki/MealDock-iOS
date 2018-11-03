//
//  GooglePhoto+Upload.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/13.
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
        freshToken(token: { (token) in
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-type": "application/octet-stream",
                "X-Goog-Upload-File-Name": "\(timeIntervalStr).jpg",
                "X-Goog-Upload-Protocol": "raw"
            ]
            guard let data = UIImagePNGRepresentation(image) else {
                let optionalError = OptionalError(with: .failedToGetPhotoData, userInfo: nil)
                failure?(optionalError)
                return
            }
            Alamofire.upload(data, to: URL(string: endpoint)!, method: HTTPMethod.post, headers: headers)
                .responseString(completionHandler: { (response) in
                    debugPrint("(・∀・)uploadToken: \(response)")
                    guard let uploadToken = response.value else {
                        let optionalError = OptionalError(with: .failedToGetToken, userInfo: nil)
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
        freshToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            guard let albumId = self.albumId else {
                self.createMealDockAlbumIfNeed()
                let optionalError = OptionalError(with: .failedToCreatePhotoSaveSpace, userInfo: nil)
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
                    guard let value = data.result.value as? [String : [Any]] else {
                        let error = (data.result.error != nil ? data.result.error!
                            : OptionalError(with: .failedToCreatePhotoSaveSpace, userInfo: nil)
                            )
                        if let errorData = data.data, let errorJson = try? JSONDecoder().decode(GooglePhotosErrorMedia.self, from: errorData) {
                            if errorJson.error.code == 400 {
                                self.forceRecreateAlbum()
                            }
                        }
                        print(error)
                        result?("", error)
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
