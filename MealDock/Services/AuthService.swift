//
//  AuthService.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/09.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

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
}
