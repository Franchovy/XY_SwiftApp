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
    
    func uploadImageToStorage(imageData: Data, storagePath: String, onProgress: @escaping((Double) -> Void), onComplete: @escaping((Result<Void, Error>) -> Void)) {
        
        let path = root.child(storagePath)
        print("Uploading image data to firebaseStorage path: \(path.fullPath)")
        
        let uploadTask = path.putData(imageData)
        
        uploadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress {
                onProgress(progress.fractionCompleted)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            onComplete(.success(()))
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
    
    func uploadVideoToStorage(videoFileUrl: URL, storagePath: String, onProgress: @escaping((Double) -> Void), onComplete: @escaping((Result<Void, Error>) -> Void)) {
        let path = root.child(storagePath)
        print("Uploading video file to firebaseStorage path: \(path.fullPath)")
        
        let uploadTask = path.putFile(from: videoFileUrl)
        
        uploadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress {
                onProgress(progress.fractionCompleted)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            onComplete(.success(()))
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
    
    var downloadQueue: DispatchQueue?
    
    func initializeDownloadQueue() {
        downloadQueue = DispatchQueue(label: "downloadQueue")
        
    }
    
    func downloadImage(from path: String, onProgress: @escaping((Double) -> Void), completion: @escaping(Result<Data, Error>) -> Void) {
        if downloadQueue == nil {
            initializeDownloadQueue()
        }
        
        downloadQueue!.async {
            let downloadTask = self.root.child(path).getData(maxSize: .max) { (data, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    completion(.success(data))
                }
            }
            
            downloadTask.observe(.progress) { (snapshot) in
                if let progress = snapshot.progress {
                    onProgress(progress.fractionCompleted)
                }
            }
        }
    }
    
    func getVideoDownloadUrl(from path: String, onCompletion: @escaping(Result<URL, Error>) -> Void) {
        if downloadQueue == nil {
            initializeDownloadQueue()
        }
        
        self.root.child(path).downloadURL { (url, error) in
            if let error = error {
                onCompletion(.failure(error))
            } else if let url = url {
                onCompletion(.success(url))
            }
        }
    }
}
