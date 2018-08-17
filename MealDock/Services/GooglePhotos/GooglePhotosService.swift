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
    static let keyAuthState = "sharingAuthState"

    let clientId = "1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l.apps.googleusercontent.com"
    let redirect = "com.googleusercontent.apps.1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l:https://watarusuzuki.github.io/MealDock/index.html"

    let sharingScope = "https://www.googleapis.com/auth/photoslibrary"
    var currentExternalUserAgentSession: OIDExternalUserAgentSession?
    private(set) var ownAuthState: OIDAuthState?
    private(set) var sharingAuthState: OIDAuthState?
    
    var albumId: String?
    var shareToken: String?
    var shareableUrl: String?
    let mediaItemSize = 250
    
    let authorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"
    let tokenEndpoint = "https://www.googleapis.com/oauth2/v4/token"
    
    var serviceConfiguration: OIDServiceConfiguration {
        get {
            return OIDServiceConfiguration(authorizationEndpoint: URL(string: authorizationEndpoint)!, tokenEndpoint: URL(string: tokenEndpoint)!)
        }
    }
    var authorizationRequest :OIDAuthorizationRequest {
        get {
            return OIDAuthorizationRequest(
                configuration: serviceConfiguration,
                clientId: clientId,
                scopes: [OIDScopeProfile, sharingScope],
                redirectURL: URL(string: redirect)!,
                responseType: OIDResponseTypeCode,
                additionalParameters: nil)
        }
    }

    private override init() {
        super.init()
        loadAuthState()
    }
    
    func saveSharingAuthState(state: OIDAuthState?) {
        if let authState = state {
            self.ownAuthState = authState
            let data = NSKeyedArchiver.archivedData(withRootObject: authState)
            UserDefaults.standard.set(data, forKey: GooglePhotosService.keyAuthState)
            UserDefaults.standard.synchronize()
            createMealDockAlbumIfNeed()
        }
    }
    
    func loadAuthState() {
        if let handleAuthStateData = UserDefaults.standard.object(forKey: GooglePhotosService.keyAuthState) as? Data {
            ownAuthState = NSKeyedUnarchiver.unarchiveObject(with: handleAuthStateData) as? OIDAuthState
        }
        createMealDockAlbumIfNeed()
    }
    
    func initSharingAuthState(token: String) {
        let fakeResponse = OIDAuthorizationResponse(request: authorizationRequest, parameters: [:])
        sharingAuthState = OIDAuthState(refreshToken: token, andResponse: fakeResponse)
    }

    func removeAuthStatus() {
        ownAuthState = nil
        sharingAuthState = nil
        UserDefaults.standard.removeObject(forKey: GooglePhotosService.keyAuthState)
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
        
}
