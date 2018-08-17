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
        let request = authorizationRequest
        
        let customError = OptionalError(with: OptionalError.Cause.failedToGetToken, userInfo: nil)
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
                if let refreshToken = state?.refreshToken {
                    FirebaseService.shared.updatePhotosApiToken(token: refreshToken)
                }
            default:
                break
            }
        })
    }
    
    func freshToken(token:((String)->Void)?, failure:((Error)->Void)?) {
        var targetAuthState = ownAuthState
        if let user = FirebaseService.shared.currentUser, user.core.uid != user.dockID {
            targetAuthState = sharingAuthState
        }
        guard let authState = targetAuthState else {
            requestOAuth2(scope: sharingScope, token: token, failure: failure)
            return
        }
    }
    
    private func performFreshToken(authState: OIDAuthState, token:((String)->Void)?, failure:((Error)->Void)?) {
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
