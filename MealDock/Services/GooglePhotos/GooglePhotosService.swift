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
    let scope = "https://www.googleapis.com/auth/photoslibrary.sharing"
    let redirect = "com.googleusercontent.apps.1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l:https://watarusuzuki.github.io/MealDock/index.html"

    var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    //var currentExternalUserAgentSession: OIDExternalUserAgentSession?
    var authState: OIDAuthState?
    var hasAuthState: Bool {
        return authState != nil
    }
    var albumId: String?
    var shareToken: String?
    var shareableUrl: String?

    private override init() {
        super.init()
        loadAuthState()
    }
    
    func requestOAuth2(token:((String)->Void)?, failure:((Error)->Void)?) {
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
                currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: controller, callback: { (state, error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.authState = state
                        self.saveAuthState()
                    }
                })
            }
        }
    }
    
    func freshToken(token:((String)->Void)?, failure:((Error)->Void)?)  {
        guard let authState = self.authState else {
            requestOAuth2(token: token, failure: failure)
            return
        }
        
        authState.performAction { (accessToken, idToken, error) in
            if let error = error {
                print(error)
                failure?(error)
            } else {
                token?(accessToken!)
            }
        }
    }
    
    func saveAuthState() {
        if let authState = self.authState {
            let data = NSKeyedArchiver.archivedData(withRootObject: authState)
            UserDefaults.standard.set(data, forKey: "authState")
            UserDefaults.standard.synchronize()
            createMealDockAlbumIfNeed()
        }
    }
    
    func loadAuthState() {
        guard let data = UserDefaults.standard.object(forKey: "authState") as? Data else {
            return
        }
        self.authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState
        self.createMealDockAlbumIfNeed()
    }
    
    
//    fileprivate func saveLastTokenResponse() {
//        guard let lastTokenResponse = self.authState?.lastTokenResponse else {
//            print("Not found last token response...")
//            return
//        }
//        self.saveTokenInfo(key: "accessToken", value: lastTokenResponse.accessToken)
//        self.saveTokenInfo(key: "idToken", value: lastTokenResponse.idToken)
//        self.saveTokenInfo(key: "refreshToken", value: lastTokenResponse.refreshToken)
//        if let accessTokenExpirationDate = lastTokenResponse.accessTokenExpirationDate {
//            self.saveTokenInfo(key: "accessTokenExpirationDate", value: String(describing: accessTokenExpirationDate.timeIntervalSince1970))
//        }
//    }
//
//    fileprivate func saveTokenInfo(key: String, value: String?) {
//        guard let tokenValue = value else {
//            print("(・A・) \(key) is not found.")
//            return
//        }
//        debugPrint("(・∀・) \(key):\(tokenValue)")
//        A0SimpleKeychain().setString(tokenValue, forKey: key + "_" + clientId)
//    }
//
//    fileprivate func loadTokenInfo(key: String) -> String? {
//        return A0SimpleKeychain().string(forKey: key + "_" + clientId)
//    }

    func isSourceApplication(url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if let current = currentAuthorizationFlow {
            if current.resumeAuthorizationFlow(with: url) {
                currentAuthorizationFlow = nil
                return true
            }
        }
        return false
    }
    
    func createMealDockAlbumIfNeed() {
        albumId = A0SimpleKeychain().string(forKey: "albumId" + "_" + clientId)
        shareToken = A0SimpleKeychain().string(forKey: "shareToken" + "_" + self.clientId)
        shareableUrl = A0SimpleKeychain().string(forKey: "shareableUrl" + "_" + self.clientId)
        if albumId != nil && shareToken != nil && shareableUrl != nil {
            return
        }

        let endpoint = "https://photoslibrary.googleapis.com/v1/albums"
        let param = ["album": ["title": "Meal Dock Shared"]] as [String : Any]
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
    
    func uploadDishPhoto(image: UIImage, uploadedMediaId:((String) -> Void)?, failure :((Error?) -> ())?) {
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
        freshToken(token: { (token) in
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
    
    func getMediaItem() {
        let MEDIA_ITEM_ID = "AId162nzuovH1DQDWcT6Xva2webr1RAEGzNE0CV7i_5lIa9p6o78njEXd8qdcywzXYkAaqmiQUK8tB6aLnxFoT6SvsBuOpokmg"
        let endpoint = "https://photoslibrary.googleapis.com/v1/mediaItems/" + MEDIA_ITEM_ID
        freshToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            Alamofire.request(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                .responseJSON(completionHandler: { (dataResponse) in
                    guard dataResponse.result.error == nil, let json = dataResponse.result.value else {
                        print(dataResponse.result.error!)
                        return
                    }
                    debugPrint(json)
                    // print ->
//                    {
//                        baseUrl = "https://lh3.googleusercontent.com/lr/AJ_cxPa9Jy4xcQ0DtCzW3_u7maoaCACwI3_tJf7koHp5r5l1BL0es9LM8jeyMg4YbEm6OvkN6V8rDBmgcZPIaEfdkwSCA1Nv2NzUD6h_xxc_Ziw-Ef5_cb4Jy9bHaRgEsBOzU96PGR8LNzjLyA5VQpxLCv2DvpYlQMKD-csGoJVojm5NRJefetcSL5RNzXkZxBzgN0N-4x8-FzoWaZv-QkUOmfyn1iWcanRLK2MZzFbk2qIKgSeoOV0VY-oGKvZVagjgMI89QHTaDZE9UkYmgtwB7SeWLu5Tr3MJxiJ8XfYYGgiPQJg2LcBh0dDJqJkphGkqyniK5VIgYK6O01HNMJZD3kZs6zR348P48_wfoAvT1IkowUnrKkbyxdUZFUYCfoPnluJIZjwEbr7f89y6JO7VgIS0KMJAuHk11YRhAF9FcmqVbwkM-ryJm34_vTFgsIm7LBSZqBCTYix5SZynnjfRp4FNZHVY5NF7QuDAaAr_UA2ILc6x-JW0IERwtxIaX3yQwwC6Hy-WhTda-soVDmPyIq51Cr88B_eqTNVR69HliI_sXzWEtt6EH25jQ-odXDqXXln1OMCKlz5_362nSCvEJKJ-XraPRMMfkJIVDBIDeP9ALTGCw-bn53NkDUfrHE56HQHJfWJzZnaSrQKhGtvDzuDkDln-SsMZ1p9rcAgEBcnXqKUvwALS_BtGq-Y6tCopkIvkchpYEHEITXIDPcVIIoKrW5XgDcjjQM1WYXfJbD0FRrErBFs797uN1ma53KtMvvdY3kvMB6BXNeWQik6EHmCdaBKEY2dotnVBsCIbKZ60rOa3-vmpnQnIkx5-BBiU9erS_iVm7YpDtjdo0ExdQnJSl5K8bcrPlTSe7kbiTcTjgg";
//                        description = "Hoge Fuga";
//                        filename = "Fuga.jpg";
//                        id = "AId162nzuovH1DQDWcT6Xva2webr1RAEGzNE0CV7i_5lIa9p6o78njEXd8qdcywzXYkAaqmiQUK8tB6aLnxFoT6SvsBuOpokmg";
//                        mediaMetadata =     {
//                            creationTime = "2018-10-10T08:53:02Z";
//                            height = 72;
//                            photo =         {
//                            };
//                            width = 72;
//                        };
//                        mimeType = "image/png";
//                        productUrl = "https://photos.google.com/lr/photo/AId162nzuovH1DQDWcT6Xva2webr1RAEGzNE0CV7i_5lIa9p6o78njEXd8qdcywzXYkAaqmiQUK8tB6aLnxFoT6SvsBuOpokmg";
//                    }

                })
        }) { (error) in
            print(error)
        }
    }
    
    func getSampleUrl() -> String {
        let sampleBaseUrl = "https://lh3.googleusercontent.com/lr/AJ_cxPa9Jy4xcQ0DtCzW3_u7maoaCACwI3_tJf7koHp5r5l1BL0es9LM8jeyMg4YbEm6OvkN6V8rDBmgcZPIaEfdkwSCA1Nv2NzUD6h_xxc_Ziw-Ef5_cb4Jy9bHaRgEsBOzU96PGR8LNzjLyA5VQpxLCv2DvpYlQMKD-csGoJVojm5NRJefetcSL5RNzXkZxBzgN0N-4x8-FzoWaZv-QkUOmfyn1iWcanRLK2MZzFbk2qIKgSeoOV0VY-oGKvZVagjgMI89QHTaDZE9UkYmgtwB7SeWLu5Tr3MJxiJ8XfYYGgiPQJg2LcBh0dDJqJkphGkqyniK5VIgYK6O01HNMJZD3kZs6zR348P48_wfoAvT1IkowUnrKkbyxdUZFUYCfoPnluJIZjwEbr7f89y6JO7VgIS0KMJAuHk11YRhAF9FcmqVbwkM-ryJm34_vTFgsIm7LBSZqBCTYix5SZynnjfRp4FNZHVY5NF7QuDAaAr_UA2ILc6x-JW0IERwtxIaX3yQwwC6Hy-WhTda-soVDmPyIq51Cr88B_eqTNVR69HliI_sXzWEtt6EH25jQ-odXDqXXln1OMCKlz5_362nSCvEJKJ-XraPRMMfkJIVDBIDeP9ALTGCw-bn53NkDUfrHE56HQHJfWJzZnaSrQKhGtvDzuDkDln-SsMZ1p9rcAgEBcnXqKUvwALS_BtGq-Y6tCopkIvkchpYEHEITXIDPcVIIoKrW5XgDcjjQM1WYXfJbD0FRrErBFs797uN1ma53KtMvvdY3kvMB6BXNeWQik6EHmCdaBKEY2dotnVBsCIbKZ60rOa3-vmpnQnIkx5-BBiU9erS_iVm7YpDtjdo0ExdQnJSl5K8bcrPlTSe7kbiTcTjgg"
        return sampleBaseUrl + "=w100-h100"
    }
}
