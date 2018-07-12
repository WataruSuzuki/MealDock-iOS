//
//  Firebase+Storage.swift
//  MealDock
//
//  Created by 鈴木 航 on 2018/10/06.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import Foundation

extension FirebaseService {
    
    func downloadURL(path: String, success:((URL) -> Void)?, failure failureBlock : ((Error) -> ())?) {
        let downloadUrlRef = storageRef.child(path)
        
        downloadUrlRef.downloadURL { url, error in
            if let url = url {
                success?(url)
            } else {
                failureBlock?(error!)
            }
        }
    }
    
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
            observeUploadTask(task: uploadTask, success: { (path) in
                debugPrint(path)
            }) { (error) in
                print(error ?? "error")
            }
        }
    }
    
    func uploadDishPhoto(image: UIImage, uploadedPath:((String) -> Void)?, failure failureBlock : ((Error?) -> ())?) {
        if let data = UIImagePNGRepresentation(image) {
            // Create the file metadata
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            if let uploadRef = getUploadReference() {
                let length = data.count / 1024 / 1024
                debugPrint("(・∀・) data.length = \(length) MB")
                updatedStorageUserInfo(value: (userInfo?.storage ?? 0) + length)
                let uploadTask = uploadRef.putData(data, metadata: metadata)
                observeUploadTask(task: uploadTask, success: { (path) in
                    uploadedPath?(path)
                }) { (error) in
                    print(error ?? "error")
                }
            }
        }
    }
    
    fileprivate func getUploadReference() -> StorageReference? {
        if let user = currentUser, let bundleId = Bundle.main.bundleIdentifier {
            let uploadRef = storageRef.child("user/\(user.uid)/\(bundleId)/images/\(Date().timeIntervalSince1970).png")
            return uploadRef
        }
        return nil
    }
    
    fileprivate func observeUploadTask(task: StorageUploadTask, success:((String) -> Void)?, failure failureBlock : ((Error?) -> ())?) {
        
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
            success?(snapshot.reference.fullPath)
        }
        
        task.observe(.failure) { snapshot in
            debugPrint("(・∀・) Upload failure: \(snapshot)")
            if let nsError = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: nsError.code)!) {
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
            failureBlock?(snapshot.error)
        }
    }
}
