//
//  AuthService.swift
//  MealDock
// 1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l
//  Created by 鈴木 航 on 2018/10/09.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

class AuthService: NSObject {
    static let shared: AuthService = {
        return AuthService()
    }()
    
    var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    var authState: OIDAuthState?

    func oauth2() {
        let authorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"
        let tokenEndpoint = "https://www.googleapis.com/oauth2/v4/token"
        
        let configuration = OIDServiceConfiguration(authorizationEndpoint: URL(string: authorizationEndpoint)!, tokenEndpoint: URL(string: tokenEndpoint)!)
        
        let issuer = "https://accounts.google.com"
        OIDAuthorizationService.discoverConfiguration(forIssuer: URL(string: issuer)!) { (configuration, error) in
            if let error = error {
                
            }
        }
        
        let clientId = "hogefuga.apps.googleusercontent.com"
        let scope = "https://www.googleapis.com/auth/photoslibrary"
        let redirect = "com.googleusercontent.apps.hogefuga"
        let responseType = ""
        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: clientId,
            scopes: [OIDScopeProfile, scope],
            redirectURL: URL(string: redirect)!,
            responseType: responseType,
            additionalParameters: nil)
    }
}
