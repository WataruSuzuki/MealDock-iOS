//
//  AuthService.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/09.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import Alamofire

class GooglePhotosService: NSObject {
    static let shared: GooglePhotosService = {
        return GooglePhotosService()
    }()
    
    let clientId = "1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l.apps.googleusercontent.com"
    let redirect = "com.googleusercontent.apps.1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l:https://watarusuzuki.github.io/MealDock/index.html"

    let executerScope = "https://www.googleapis.com/auth/photoslibrary.sharing"
    let readScope = "https://www.googleapis.com/auth/photoslibrary.readonly.appcreateddata"
    var currentExternalUserAgentSession: OIDExternalUserAgentSession?
    var readAuthState: OIDAuthState?
    var handleAuthState: OIDAuthState?
    var albumId: String?
    var shareToken: String?
    var shareableUrl: String?
    let mediaItemSize = 250

    private override init() {
        super.init()
        loadAuthState()
    }
    
    fileprivate func requestOAuth2(scope: String, token:((String)->Void)?, failure:((Error)->Void)?) {
        let authorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"
        let tokenEndpoint = "https://www.googleapis.com/oauth2/v4/token"
        
        let configuration = OIDServiceConfiguration(authorizationEndpoint: URL(string: authorizationEndpoint)!, tokenEndpoint: URL(string: tokenEndpoint)!)
        
        //Or through discovery:
        /*
        let issuer = "https://accounts.google.com"
        OIDAuthorizationService.discoverConfiguration(forIssuer: URL(string: issuer)!) { (configuration, error) in
            if let error = error {
                
            }
        }
        */
        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: clientId,
            scopes: [OIDScopeProfile, scope],
            redirectURL: URL(string: redirect)!,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil)
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let controller = delegate.window?.rootViewController {
                currentExternalUserAgentSession = OIDAuthState.authState(byPresenting: request, presenting: controller, callback: { (state, error) in
                    if let error = error {
                        print(error)
                    } else {
                        switch scope {
                        case self.executerScope:
                            self.saveExecuterAuthState(state: state)
                        case self.readScope:
                            self.saveReadAuthState(state: state)
                        default:
                            break
                        }
                    }
                })
            }
        }
    }
    
    fileprivate func freshExecuterToken(token:((String)->Void)?, failure:((Error)->Void)?)  {
        guard let authState = self.handleAuthState else {
            requestOAuth2(scope: executerScope, token: token, failure: failure)
            return
        }
        freshToken(authState: authState, token: token, failure: failure)
    }
    
    fileprivate func freshReaderToken(token:((String)->Void)?, failure:((Error)->Void)?)  {
        guard let authState = self.readAuthState else {
            requestOAuth2(scope: readScope, token: token, failure: failure)
            return
        }
        freshToken(authState: authState, token: token, failure: failure)
    }
    
    fileprivate func freshToken(authState: OIDAuthState, token:((String)->Void)?, failure:((Error)->Void)?) {
        authState.performAction { (accessToken, idToken, error) in
            if let error = error {
                print(error)
                failure?(error)
            } else {
                token?(accessToken!)
            }
        }
    }

    fileprivate func saveExecuterAuthState(state: OIDAuthState?) {
        if let authState = state {
            self.handleAuthState = authState
            let data = NSKeyedArchiver.archivedData(withRootObject: authState)
            UserDefaults.standard.set(data, forKey: "handleAuthState")
            UserDefaults.standard.synchronize()
            createMealDockAlbumIfNeed()
        }
    }
    
    fileprivate func saveReadAuthState(state: OIDAuthState?) {
        if let authState = state {
            self.readAuthState = authState
            let data = NSKeyedArchiver.archivedData(withRootObject: authState)
            UserDefaults.standard.set(data, forKey: "readAuthState")
            UserDefaults.standard.synchronize()
        }
    }
    
    class func removeAuthStatus()  {
        UserDefaults.standard.removeObject(forKey: "readAuthState")
        UserDefaults.standard.removeObject(forKey: "handleAuthState")
    }
    
    fileprivate func loadAuthState() {
        if let handleAuthStateData = UserDefaults.standard.object(forKey: "handleAuthState") as? Data {
            self.handleAuthState = NSKeyedUnarchiver.unarchiveObject(with: handleAuthStateData) as? OIDAuthState
        }
        if let readAuthStateData = UserDefaults.standard.object(forKey: "readAuthState") as? Data {
            self.readAuthState = NSKeyedUnarchiver.unarchiveObject(with: readAuthStateData) as? OIDAuthState
        }
        self.createMealDockAlbumIfNeed()
    }
    
    func isSourceApplication(url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if let current = currentExternalUserAgentSession {
            if current.resumeExternalUserAgentFlow(with: url) {
                currentExternalUserAgentSession = nil
                return true
            }
        }
        return false
    }
    
    fileprivate func createMealDockAlbumIfNeed() {
        albumId = A0SimpleKeychain().string(forKey: "albumId" + "_" + clientId)
        shareToken = A0SimpleKeychain().string(forKey: "shareToken" + "_" + self.clientId)
        shareableUrl = A0SimpleKeychain().string(forKey: "shareableUrl" + "_" + self.clientId)
        if albumId != nil && shareToken != nil && shareableUrl != nil {
            return
        }

        let endpoint = "https://photoslibrary.googleapis.com/v1/albums"
        let param = ["album": ["title": "Meal Dock Shared"]] as [String : Any]
        freshExecuterToken(token: { (token) in
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
                    A0SimpleKeychain().setString(result.id, forKey: "albumId" + "_" + self.clientId)
                    self.albumId = result.id
                    self.sharingAlbum(ALBUM_ID: result.id)
                } catch let error {
                    print(error)
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    fileprivate func sharingAlbum(ALBUM_ID: String) {
        let endpoint = "https://photoslibrary.googleapis.com/v1/albums/\(ALBUM_ID):share"
        let param = ["sharedAlbumOptions": ["isCollaborative": true, "isCommentable": true]] as [String : Any]
        freshExecuterToken(token: { (token) in
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
    
    func uploadDishPhoto(image: UIImage, uploadedMediaId:((String) -> Void)?, failure :((Error?) -> ())?) {
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
                failure?(NSError(domain: "errorメッセージ", code: -1, userInfo: nil))
                return
            }
            Alamofire.upload(data, to: URL(string: endpoint)!, method: HTTPMethod.post, headers: headers)
                .responseString(completionHandler: { (response) in
                    debugPrint("(・∀・)uploadToken: \(response)")
                    guard let uploadToken = response.value else {
                        failure?(NSError(domain: "errorメッセージ", code: -1, userInfo: nil))
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
    
    func creatingMediaItem(uploadToken:String, result:((String, Error?) -> Void)?) {
        let endpoint = "https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate"
        freshExecuterToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            guard let albumId = self.albumId else {
                result?("", NSError(domain: "errorメッセージ", code: -1, userInfo: nil))
                return
            }
            let param = [
                "albumId": "\(albumId)",
                "newMediaItems": [
                    "description": "Hoge Fuga",
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
    
    func getMediaItemUrl(MEDIA_ITEM_ID: String, result:((String, Error?) -> Void)?) {
        let endpoint = "https://photoslibrary.googleapis.com/v1/mediaItems/" + MEDIA_ITEM_ID
        freshReaderToken(token: { (token) in
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
