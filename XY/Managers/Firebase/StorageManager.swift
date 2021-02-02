//
//  StorageManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/02/2021.
//

import Foundation
import UIKit
import FirebaseStorage
import Kingfisher

final class StorageManager {
    static let shared = StorageManager()
    private init() { }
    
    let storage = Storage.storage()
    
    enum ImageUploadFailure : Error {
        case failedToGenerateThumbnail
        case failedToCreatePNG
    }
    
    // MARK: - Public functions
    
    /// Uses storageId as folder, containing image (original), and thumbnail image. Id should match PostId, ViralId, etc.
    public func uploadPhoto(_ image: UIImage, storageId: String, completion: @escaping(Result<String, Error>) -> Void) {
        var uuid: String!
        let metadata = StorageMetadata()
        
        var imageData = image.pngData()!
        if imageData.count > 5 * 1024 * 1024 {
            while imageData.count > 5 * 1024 * 1024 {
                imageData = image.jpegData(compressionQuality: 1.0)!
            }
            uuid = UUID().uuidString + ".jpg"
            metadata.contentType = "image/jpeg"
        } else {
            metadata.contentType = "image/png"
            uuid = UUID().uuidString + ".png"
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child(storageId).child(uuid)
        
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                self.uploadThumbnail(forImage: image, withPath: storageId, withId: uuid) { (result) in
                    switch result {
                    case .success(let bool):
                        if bool {
                            completion(.success(uuid))
                        } else {
                            completion(.failure(ImageUploadFailure.failedToGenerateThumbnail))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    public func getDownloadUrl(_ containerId: String, _ imageId: String, completion: @escaping(Result<URL, Error>) -> Void) {
        let storageRef = storage.reference(withPath: containerId)
        
        let imageRef = storageRef.child(imageId)
        
        imageRef.downloadURL { (url, error) in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
    }
    
    public func downloadThumbnail(withContainerId folderId: String, withImageId imageId: String, completion: @escaping(Result<UIImage, Error>) -> Void) {
        let thumbnailId = imageId.replacingOccurrences(of: ".", with: "_thumbnail.")
        downloadImage(withContainerId: folderId, withImageId: thumbnailId, completion: completion)
    }
    
    public func downloadImage(withContainerId folderId: String, withImageId imageId: String, completion: @escaping(Result<UIImage, Error>) -> Void) {
        let storageRef = storage.reference(withPath: folderId)
        
        let imageRef = storageRef.child(imageId)
        
        getDownloadUrl(folderId, imageId) { (result) in
            switch result {
            case .success(let url):
                self.downloadImageWithKingfisher(imageUrl: url) { (image, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let image = image {
                        completion(.success(image))
                    }
                }
            case .failure(let error):
                // backup - call with the old storage pattern
                ImageDownloaderHelper.shared.getFullURL(imageId: imageId) { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        self.downloadImageWithKingfisher(imageUrl: url) { (image, error) in
                            if let error = error {
                                completion(.failure(error))
                            } else if let image = image {
                                completion(.success(image))
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func uploadVideo(from url: URL, withThumbnail image: UIImage, withContainer containerId: String, completion: @escaping(Result<String,Error>) -> Void) {
        var uuid: String!
        let metadata = StorageMetadata()
        
        uuid = UUID().uuidString + ".mov"
        metadata.contentType = "video/quicktime"
        
        let storageRef = storage.reference()
        let videoRef = storageRef.child(containerId).child(uuid)
        
        videoRef.putFile(from: url, metadata: metadata)  { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                self.uploadThumbnail(forImage: image, withPath: containerId, withId: uuid) { (result) in
                    switch result {
                    case .success(let bool):
                        if bool {
                            completion(.success(uuid))
                        } else {
                            completion(.failure(ImageUploadFailure.failedToGenerateThumbnail))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    // MARK: - Private functions
    
    private func downloadImageWithKingfisher(imageUrl: URL, completion: @escaping(UIImage?, Error?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
            // Update download progress
        }, downloadTaskUpdated: { task in
            // Download task update
            
        }, completionHandler: { result in
            do {
                let image = try result.get().image
                completion(image, nil)
            } catch let error {
                completion(nil, error)
            }
        })
    }
    
    private func uploadThumbnail(forImage image: UIImage, withPath path: String, withId imageId: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        guard let thumbnailImage = image.generateThumbnail() else {
            completion(.failure(ImageUploadFailure.failedToGenerateThumbnail))
            return
        }
        guard let imageData = thumbnailImage.jpegData(compressionQuality: 1.0) else {
            completion(.failure(ImageUploadFailure.failedToCreatePNG))
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"

        let thumbnailId = imageId.replacingOccurrences(of: ".", with: "_thumbnail.")
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child(path).child(thumbnailId)
        
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
}
