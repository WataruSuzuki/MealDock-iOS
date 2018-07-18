//
//  AuthService.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/09.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit
import Alamofire

class AuthService: NSObject {
    static let shared: AuthService = {
        return AuthService()
    }()
    
    let clientId = "1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l.apps.googleusercontent.com"
    let scope = "https://www.googleapis.com/auth/photoslibrary"
    let redirect = "com.googleusercontent.apps.1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l:https://watarusuzuki.github.io/MealDock/index.html"

    var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    //var currentExternalUserAgentSession: OIDExternalUserAgentSession?
    var authState: OIDAuthState?

    
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
        
//        if let accessToken = authState.lastTokenResponse?.accessToken,
//            let expirationDate = loadTokenInfo(key: "accessTokenExpirationDate"),
//            TimeInterval(expirationDate)! >= NSDate().timeIntervalSince1970 {
//            token?(accessToken)
//        }
        authState.performAction { (accessToken, idToken, error) in
            if let error = error {
                print(error)
                failure?(error)
            } else {
//                self.saveTokenInfo(key: "accessToken", value: accessToken)
//                self.saveTokenInfo(key: "idToken", value: idToken)
                token?(accessToken!)
            }
        }
    }
    
    func saveAuthState() {
        if let authState = self.authState {
            let data = NSKeyedArchiver.archivedData(withRootObject: authState)
            UserDefaults.standard.set(data, forKey: "authState")
            UserDefaults.standard.synchronize()
        }
    }
    
    func loadAuthState() {
        guard let data = UserDefaults.standard.object(forKey: "authState") as? Data else {
            return
        }
        self.authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState
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
    
    func createAlbum() {
        let endpoint = "https://photoslibrary.googleapis.com/v1/albums"
        let param = ["album": ["title": "New Album Title"]] as [String : Any]
        freshToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            Alamofire.request(endpoint, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { (dataResponse) in
                guard dataResponse.result.error == nil, let json = dataResponse.result.value as? [String: Any] else  {
                    print(dataResponse.result.error!)
                    return
                }
                debugPrint(json)
                //print -> [
                // "title": New Album Title,
                // "productUrl": https://photos.google.com/lr/album/AId162mrLD6C0meIru3zSbat552DYzs_KVQr_rUTXV_ZnEwR7dQ0oyDYwjDZcXAm2QhSloueHs8O,
                // "id": AId162mrLD6C0meIru3zSbat552DYzs_KVQr_rUTXV_ZnEwR7dQ0oyDYwjDZcXAm2QhSloueHs8O
                //]
            }
        }) { (error) in
            print(error)
        }
    }
    
    func uploadMediaByteData() {
        let endpoint = "https://photoslibrary.googleapis.com/v1/uploads"
        freshToken(token: { (token) in
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-type": "application/octet-stream",
                "X-Goog-Upload-File-Name": "Fuga.jpg",
                "X-Goog-Upload-Protocol": "raw"
            ]
            let image = UIImage(named: "baseline_local_dining_black_36pt")!
            if let data = UIImagePNGRepresentation(image) {
                Alamofire.upload(data, to: URL(string: endpoint)!, method: HTTPMethod.post, headers: headers)
                    .responseString(completionHandler: { (responseString) in
                        debugPrint("(・∀・) \(responseString)")
                        //print -> CAISiQMA7p/vKOLTIJYCsVjfPPWIU1TDOU6o0aHQguR0remytyxnWzj4uAhQhxFqqTQeyBEs8ZuHP3GTcz9CqSWdSbCJla88s9wrHvc5m8f3KEyx3CILqg/cDNMKcFYOrBk9xfDah6s67n734SohJQvBjZd9hRam8fiWFDyWyYQ2W6khxhXaBLkJc0iW8wn+NO7WWxWcHFwAwoqNH7jJ5/OkcWnolvKMmeGCbTFEAKTm55PkiBIpI3Z2RE8YLFGji8brcMBxl+x7mDugANFlr3SB/XaCFcMFG0xrPtQuVh8jLbA3ydM4yKzzIbBNfz5vDnQddjbbtSNsubdX1F6lgxpN4QWAcLNez2GOBRXVnkjmwzYmnAvxXCq+GElUqvXOYfZs/2Js0Zyl+QQ9paEhn92Dnpgz8a1Ee+917Muvu+LymnQSiobK1jsP+Lk2dOpsXAM7MyRfIIQOnkLDJj46f17ova1HI0xJyH6XGOWJPxlaaCx+pHIwKFKSpABTp0xtNxJJqtmi+JdZENkzGKw
                    })
            }
        }) { (error) in
            print(error)
        }
    }
    
    func creatingMediaItem() {
        let endpoint = "https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate"
        let uploadToken = "CAISiQMA7p/vKOLTIJYCsVjfPPWIU1TDOU6o0aHQguR0remytyxnWzj4uAhQhxFqqTQeyBEs8ZuHP3GTcz9CqSWdSbCJla88s9wrHvc5m8f3KEyx3CILqg/cDNMKcFYOrBk9xfDah6s67n734SohJQvBjZd9hRam8fiWFDyWyYQ2W6khxhXaBLkJc0iW8wn+NO7WWxWcHFwAwoqNH7jJ5/OkcWnolvKMmeGCbTFEAKTm55PkiBIpI3Z2RE8YLFGji8brcMBxl+x7mDugANFlr3SB/XaCFcMFG0xrPtQuVh8jLbA3ydM4yKzzIbBNfz5vDnQddjbbtSNsubdX1F6lgxpN4QWAcLNez2GOBRXVnkjmwzYmnAvxXCq+GElUqvXOYfZs/2Js0Zyl+QQ9paEhn92Dnpgz8a1Ee+917Muvu+LymnQSiobK1jsP+Lk2dOpsXAM7MyRfIIQOnkLDJj46f17ova1HI0xJyH6XGOWJPxlaaCx+pHIwKFKSpABTp0xtNxJJqtmi+JdZENkzGKw"
        freshToken(token: { (token) in
            let headers = ["Authorization": "Bearer \(token)"]
            let param = ["newMediaItems": [
                "description": "Hoge Fuga",
                "simpleMediaItem" : ["uploadToken": uploadToken]
                ]] as [String : Any]
            Alamofire.request(endpoint, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .responseJSON(completionHandler: { (data) in
                    guard data.result.error == nil, let json = data.result.value else {
                        print(data.result.error!)
                        return
                    }
                    debugPrint(json)
                    //print -> {
//                    newMediaItemResults =     (
//                        {
//                            mediaItem =             {
//                                description = "Hoge Fuga";
//                                filename = "Fuga.jpg";
//                                id = "AId162nzuovH1DQDWcT6Xva2webr1RAEGzNE0CV7i_5lIa9p6o78njEXd8qdcywzXYkAaqmiQUK8tB6aLnxFoT6SvsBuOpokmg";
//                                mediaMetadata =                 {
//                                    creationTime = "2018-10-10T08:53:02Z";
//                                    height = 72;
//                                    width = 72;
//                                };
//                                mimeType = "image/png";
//                                productUrl = "https://photos.google.com/lr/photo/AId162nzuovH1DQDWcT6Xva2webr1RAEGzNE0CV7i_5lIa9p6o78njEXd8qdcywzXYkAaqmiQUK8tB6aLnxFoT6SvsBuOpokmg";
//                            };
//                            status =             {
//                                message = OK;
//                            };
//                            uploadToken = "CAISiQMA7p/vKOLTIJYCsVjfPPWIU1TDOU6o0aHQguR0remytyxnWzj4uAhQhxFqqTQeyBEs8ZuHP3GTcz9CqSWdSbCJla88s9wrHvc5m8f3KEyx3CILqg/cDNMKcFYOrBk9xfDah6s67n734SohJQvBjZd9hRam8fiWFDyWyYQ2W6khxhXaBLkJc0iW8wn+NO7WWxWcHFwAwoqNH7jJ5/OkcWnolvKMmeGCbTFEAKTm55PkiBIpI3Z2RE8YLFGji8brcMBxl+x7mDugANFlr3SB/XaCFcMFG0xrPtQuVh8jLbA3ydM4yKzzIbBNfz5vDnQddjbbtSNsubdX1F6lgxpN4QWAcLNez2GOBRXVnkjmwzYmnAvxXCq+GElUqvXOYfZs/2Js0Zyl+QQ9paEhn92Dnpgz8a1Ee+917Muvu+LymnQSiobK1jsP+Lk2dOpsXAM7MyRfIIQOnkLDJj46f17ova1HI0xJyH6XGOWJPxlaaCx+pHIwKFKSpABTp0xtNxJJqtmi+JdZENkzGKw";
//                        }
//                    );
//            }

                })
        }) { (error) in
            print(error)
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
