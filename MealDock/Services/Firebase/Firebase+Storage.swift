//
//  Firebase+Storage.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/06.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func uploadFile(path: String, contentType: String) {
        // Local file you want to upload
        guard let localFile = URL(string: "path/to/image") else {
            return
        }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload file and metadata to the object 'images/mountains.jpg'
        if let uploadRef = getUploadReference() {
            let uploadTask = uploadRef.putFile(from: localFile, metadata: metadata)
            upload(task: uploadTask)
        }
    }
    
    func uploadDishPhoto(image: UIImage, contentType: String) {
        if let data = UIImagePNGRepresentation(image) {
            // Create the file metadata
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            if let uploadRef = getUploadReference() {
                let uploadTask = uploadRef.putData(data, metadata: metadata)
                upload(task: uploadTask)
            }
        }
    }
    
    fileprivate func getUploadReference() -> StorageReference? {
        if let user = currentUser, let bundleId = Bundle.main.bundleIdentifier {
            let uploadRef = storageRef.child("\(bundleId)/images/\(user.uid)/\(Date().timeIntervalSince1970).png)")
            return uploadRef
        }
        return nil
    }
    
    fileprivate func upload(task: StorageUploadTask) {
        
        // Listen for state changes, errors, and completion of the upload.
        task.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
            debugPrint("(・∀・) Upload resumed: \(snapshot)")
        }
        
        task.observe(.pause) { snapshot in
            // Upload paused
            debugPrint("(・∀・) Upload paused: \(snapshot)")
        }
        
        task.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            debugPrint("(・∀・) percentComplete: \(percentComplete)")
        }
        
        task.observe(.success) { snapshot in
            // Upload completed successfully
            debugPrint("(・∀・) Upload completed successfully: \(snapshot)")
        }
        
        task.observe(.failure) { snapshot in
            debugPrint("(・∀・) Upload failure: \(snapshot)")
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
}
