//
//  FirebaseStorageManager.swift
//  XY
//
//  Created by Maxime Franchot on 16/04/2021.
//

import Foundation
import FirebaseStorage

final class FirebaseStorageManager {
    static var shared = FirebaseStorageManager()
    private init() { }
    
    let root = Storage.storage().reference()
    
    func uploadVideoToStorage(videoFileUrl: URL, filename: String? = nil, containerName: String? = nil, onProgress: @escaping((Double) -> Void), onComplete: @escaping((Result<String, Error>) -> Void)) {
        let name = filename ?? UUID().uuidString + ".mov"
        
        let path = root.child(containerName ?? UUID().uuidString).child(name)
        print("Uploading file with full path: \(path.fullPath)")
        
        let uploadTask = path.putFile(from: videoFileUrl)
        
        uploadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress {
                onProgress(progress.fractionCompleted)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            onComplete(.success(path.fullPath))
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                onComplete(.failure(error))
            } else {
                fatalError("Unknown error occured while uploading")
            }
        }
        
        uploadTask.resume()
    }
    
    func deleteFile(with path: String) {
        
    }
    
    func downloadVideo(with path: String, onProgress: @escaping((Double) -> Void), onCompletion: @escaping(Result<URL, Error>) -> Void) {
        
    }
}
