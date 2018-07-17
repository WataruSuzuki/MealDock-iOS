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

    func oauth2() {
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
                        if let accessToken = self.authState?.lastTokenResponse?.accessToken {
                            self.saveTokenInfo(key: "accessToken", value: accessToken)
                        }
                        if let idToken = self.authState?.lastTokenResponse?.idToken {
                            self.saveTokenInfo(key: "idToken", value: idToken)
                        }
                        if let refreshToken = self.authState?.lastTokenResponse?.refreshToken {
                            self.saveTokenInfo(key: "refreshToken", value: refreshToken)
                        }
                        if let accessTokenExpirationDate = self.authState?.lastTokenResponse?.accessTokenExpirationDate {
                            self.saveTokenInfo(key: "accessTokenExpirationDate", value: String(describing: accessTokenExpirationDate.timeIntervalSince1970))
                        }
                    }
                })
            }
        }
    }
    
    fileprivate func saveTokenInfo(key: String, value: String) {
        debugPrint("(・∀・) \(key):\(value)")
        A0SimpleKeychain().setString(value, forKey: key + "_" + clientId)
    }

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
