//
//  GooglePhoto+Token.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/10/13.
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
            self.saveSharingAuthState(state: state)
            if let refreshToken = state?.refreshToken {
                FirebaseService.shared.updatePhotosApiToken(token: refreshToken)
            }
        })
    }
    
    func freshToken(token:((String)->Void)?, failure:((Error)->Void)?) {
        FirebaseService.shared.waitLoadUserInfo {
            if let user = FirebaseService.shared.currentUser, user.core.uid == user.dockID {
                guard let authState = self.ownAuthState else {
                    self.requestOAuth2(scope: self.ownScope, token: token, failure: failure)
                    return
                }
                self.performFreshToken(authState: authState, token: token, failure: failure)
            } else {
                self.waitSharingAuthState {
                    guard let sharing = self.sharingAuthState else {
                        self.requestOAuth2(scope: self.ownScope, token: token, failure: failure)
                        return
                    }
                    self.performFreshToken(authState: sharing, token: token, failure: failure)
                }
            }
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
