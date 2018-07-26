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
    static let keySharingState = "sharingAuthState"
    static let keyReadingState = "readingAuthState"

    let clientId = "1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l.apps.googleusercontent.com"
    let redirect = "com.googleusercontent.apps.1098918506603-thq4jv3habfc962r7p89r31a2h4kjt1l:https://watarusuzuki.github.io/MealDock/index.html"

    let sharingScope = "https://www.googleapis.com/auth/photoslibrary.sharing"
    let readingScope = "https://www.googleapis.com/auth/photoslibrary.readonly.appcreateddata"
    var currentExternalUserAgentSession: OIDExternalUserAgentSession?
    private(set) var readingAuthState: OIDAuthState?
    private(set) var sharingAuthState: OIDAuthState?
    var albumId: String?
    var shareToken: String?
    var shareableUrl: String?
    let mediaItemSize = 250

    private override init() {
        super.init()
        loadAuthState()
    }
    
    func saveSharingAuthState(state: OIDAuthState?) {
        if let authState = state {
            self.sharingAuthState = authState
            let data = NSKeyedArchiver.archivedData(withRootObject: authState)
            UserDefaults.standard.set(data, forKey: GooglePhotosService.keySharingState)
            UserDefaults.standard.synchronize()
            createMealDockAlbumIfNeed()
        }
    }
    
    func saveReadingAuthState(state: OIDAuthState?) {
        if let authState = state {
            self.readingAuthState = authState
            let data = NSKeyedArchiver.archivedData(withRootObject: authState)
            UserDefaults.standard.set(data, forKey: GooglePhotosService.keyReadingState)
            UserDefaults.standard.synchronize()
        }
    }
    
    func loadAuthState() {
        if let handleAuthStateData = UserDefaults.standard.object(forKey: GooglePhotosService.keySharingState) as? Data {
            self.sharingAuthState = NSKeyedUnarchiver.unarchiveObject(with: handleAuthStateData) as? OIDAuthState
        }
        if let readAuthStateData = UserDefaults.standard.object(forKey: GooglePhotosService.keyReadingState) as? Data {
            self.readingAuthState = NSKeyedUnarchiver.unarchiveObject(with: readAuthStateData) as? OIDAuthState
        }
        self.createMealDockAlbumIfNeed()
    }
    

    class func removeAuthStatus()  {
        UserDefaults.standard.removeObject(forKey: keyReadingState)
        UserDefaults.standard.removeObject(forKey: keySharingState)
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
