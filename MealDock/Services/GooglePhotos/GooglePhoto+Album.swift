//
//  GooglePhoto+Album.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import Alamofire

extension GooglePhotosService {
    
    func forceRecreateAlbum() {
        A0SimpleKeychain().deleteEntry(forKey: "albumId" + "_" + clientId)
        createMealDockAlbumIfNeed()
    }
    
    func createMealDockAlbumIfNeed() {
        albumId = A0SimpleKeychain().string(forKey: "albumId" + "_" + clientId)
//        shareToken = A0SimpleKeychain().string(forKey: "shareToken" + "_" + self.clientId)
//        shareableUrl = A0SimpleKeychain().string(forKey: "shareableUrl" + "_" + self.clientId)
        if albumId != nil
//            && shareToken != nil && shareableUrl != nil
            || FirebaseService.shared.currentUser == nil
        {
            return
        }
        
        let endpoint = "https://photoslibrary.googleapis.com/v1/albums"
        let param = ["album": ["title": "Meal Dock"]] as [String : Any]
        freshToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            Alamofire.request(endpoint, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { (dataResponse) in
                guard dataResponse.result.error == nil, let value = dataResponse.result.value as? [String : Any] else  {
                    print(dataResponse.result.error!)
                    return
                }
                debugPrint(value)
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                    let result = try JSONDecoder().decode(GooglePhotosAlbum.self, from: jsonData)
                    self.saveAlbumId(id: result.id)
                    //self.sharingAlbum(ALBUM_ID: result.id)
                } catch let error {
                    print(error)
                }
            }
        }) { (error) in
            print(error)
        }
    }
    /*
    private func sharingAlbum(ALBUM_ID: String) {
        let endpoint = "https://photoslibrary.googleapis.com/v1/albums/\(ALBUM_ID):share"
        let param = ["sharedAlbumOptions": ["isCollaborative": true, "isCommentable": true]] as [String : Any]
        freshToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            Alamofire.request(endpoint, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.result.error == nil,
                        let value = dataResponse.result.value as? [String : Any] else {
                            print(dataResponse.result.error!)
                            return
                    }
                    debugPrint(value)
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        let responseJson = try JSONDecoder().decode(GooglePhotosSharedInfoResponse.self, from: jsonData)
                        
                        A0SimpleKeychain().setString(responseJson.shareInfo.shareToken, forKey: "shareToken" + "_" + self.clientId)
                        A0SimpleKeychain().setString(responseJson.shareInfo.shareableUrl, forKey: "shareableUrl" + "_" + self.clientId)
                    } catch let error {
                        print(error)
                    }
                })
        }) { (error) in
            print(error)
        }
    }
    */
    
    func saveAlbumId(id: String) {
        A0SimpleKeychain().setString(id, forKey: "albumId" + "_" + clientId)
        albumId = id
        if let user = FirebaseService.shared.currentUser, user.isGroupOwnerMode {
            FirebaseService.shared.updatePhotosAlbumId(id: id)
        }
    }
}
