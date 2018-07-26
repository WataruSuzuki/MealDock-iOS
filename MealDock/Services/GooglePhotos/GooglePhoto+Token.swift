//
//  GooglePhoto+Token.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/13.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation
import Alamofire

extension GooglePhotosService {
    
    private func requestOAuth2(scope: String, token:((String)->Void)?, failure:((Error)->Void)?) {
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
        
        let customError = CustomError(with: CustomError.ErrorType.cannotGetToken, userInfo: nil)
        guard let delegate = UIApplication.shared.delegate as? AppDelegate,
            let controller = delegate.window?.rootViewController else {
                failure?(customError)
                return
        }
        currentExternalUserAgentSession = OIDAuthState.authState(byPresenting: request, presenting: controller, callback: { (state, error) in
            guard let accessToken = state?.lastTokenResponse?.accessToken else {
                let presentError = (error != nil ? error! : customError)
                print(presentError)
                failure?(presentError)
                return
            }
            token?(accessToken)
            switch scope {
            case self.sharingScope:
                self.saveSharingAuthState(state: state)
            case self.readingScope:
                self.saveReadingAuthState(state: state)
            default:
                break
            }
        })
    }
    
    func freshExecuterToken(token:((String)->Void)?, failure:((Error)->Void)?)  {
        guard let authState = self.sharingAuthState else {
            requestOAuth2(scope: sharingScope, token: token, failure: failure)
            return
        }
        freshToken(authState: authState, token: token, failure: failure)
    }
    
    func freshReaderToken(token:((String)->Void)?, failure:((Error)->Void)?)  {
        guard let authState = self.readingAuthState else {
            requestOAuth2(scope: readingScope, token: token, failure: failure)
            return
        }
        freshToken(authState: authState, token: token, failure: failure)
    }
    
    func freshToken(authState: OIDAuthState, token:((String)->Void)?, failure:((Error)->Void)?) {
        authState.performAction { (accessToken, idToken, error) in
            if let error = error {
                print(error)
                failure?(error)
            } else {
                token?(accessToken!)
            }
        }
    }
}
