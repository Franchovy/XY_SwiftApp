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
import ImageIO
import MobileCoreServices

final class StorageManager {
    static let shared = StorageManager()
    private init() { }
    
    let storage = Storage.storage()
    
    enum ImageUploadFailure : Error {
        case failedToGenerateThumbnail
        case failedToCreatePNG
    }
    
    var downloadTasks = [URL: DownloadTask?]()
    var pendingDownloadTaskURLs = [URL: (UIImage?, Error?) -> Void]()
    let maxConcurrentDownloadTasks = 5
    
    // MARK: - Public functions
    
    public func deleteContainer(withPath path: String, completion: @escaping(Error?) -> Void) {
        storage.reference().child(path).listAll { (storageListResult, error) in
            if let error = error {
                completion(error)
            } else {
                for item in storageListResult!.items {
                    item.delete { (error) in
                        completion(error)
                    }
                }
            }
        }
    }
    
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
        let thumbnailId = imageId
            .replacingOccurrences(of: ".", with: "_thumbnail.")
            .replacingOccurrences(of: ".mov", with: ".jpeg")
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
    
    public func downloadImage(withImageId imageId: String, completion: @escaping(UIImage?, Error?) -> Void) -> StorageDownloadTask {
        let storageRef = storage.reference()
        
        let imageRef = storageRef.child(imageId)
        
        let downloadUrl = documentsUrl.appendingPathComponent(imageId)
        return imageRef.write(toFile: downloadUrl) { url, error in
            if let error = error {
                completion(nil, error)
            } else if url != nil {
                let image = UIImage(contentsOfFile: downloadUrl.path)
                completion(image, nil)
            }
        }
    }
    
    public func generateGif(photos: [UIImage], filename: String) -> Bool {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsDirectoryPath.appending(filename)
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.125]]
        let cfURL = URL(fileURLWithPath: path) as CFURL
        if let destination = CGImageDestinationCreateWithURL(cfURL, kUTTypeGIF, photos.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
                for photo in photos {
                    CGImageDestinationAddImage(destination, photo.cgImage!, gifProperties as CFDictionary?)
                }
                return CGImageDestinationFinalize(destination)
            }
        return false
    }
    
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func newDownloadFilePath(directory: FileManager.SearchPathDirectory, fileName: String) -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return URL(fileURLWithPath: fileName, relativeTo: documentDirectory)
    }
    
    var videoUploadTask: StorageUploadTask?
    
    public func subscribeToUploadProgress(onProgress: @escaping((Double) -> Void)) -> Bool {
        guard let videoUploadTask = videoUploadTask else {
            return false
        }
        
        videoUploadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress {
                onProgress(progress.fractionCompleted)
            }
        }
        return true
    }
    
    public func uploadVideo(from url: URL, withThumbnail image: UIImage, withContainer containerId: String, completion: @escaping(Result<String,Error>) -> Void) {
        var uuid: String!
        let metadata = StorageMetadata()
        
        uuid = UUID().uuidString + ".mov"
        metadata.contentType = "video/quicktime"
        
        let storageRef = storage.reference()
        let videoRef = storageRef.child(containerId).child(uuid)
        
        if let videoData = NSData(contentsOf: url) as Data? {
            //use 'putData' instead
            
            videoUploadTask = videoRef.putData(videoData, metadata: metadata) { (_, error) in
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
    }
    
    public func downloadVideo(videoId: String, containerId: String?, completion: @escaping(Result<URL, Error>) -> Void) {
        let videoDownloadRef = containerId == nil ? storage.reference().child(videoId) : storage.reference().child(containerId!).child(videoId)
        
        videoDownloadRef.downloadURL { (url, error) in
            if let error = error {
                // Try backup option, check directly in firebase storage
                let videoDownloadRef = self.storage.reference().child(videoId)
                
                videoDownloadRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    }
                }
            } else if let url = url {
              completion(.success(url))
            }
        }
    }
    
    public func cancelCurrentDownloadTasks() {
        for task in downloadTasks {
            task.value?.cancel()
        }
        downloadTasks.removeAll()
        
        pendingDownloadTaskURLs.removeAll()
    }
    
    public func getThumbnail(for videoUrl: URL) {
        
    }
    
    // MARK: - Private functions
    
    private func downloadImageWithKingfisher(imageUrl: URL, completion: @escaping(UIImage?, Error?) -> Void) {
        if downloadTasks.count < maxConcurrentDownloadTasks {
            let downloadTask = KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Update download progress
            }, downloadTaskUpdated: { task in
                // Download task update
                
            }, completionHandler: { result in
                defer {
                    self.downloadTasks.removeValue(forKey: imageUrl)
                    self.continuePendingDownloadTasks()
                }
                do {
                    let image = try result.get().image
                    completion(image, nil)
                } catch let error {
                    completion(nil, error)
                }
            })
            
            downloadTasks[imageUrl] = downloadTask
        } else {
            pendingDownloadTaskURLs[imageUrl] = completion
        }
    }
    
    private func continuePendingDownloadTasks() {
        
        if downloadTasks.count <= maxConcurrentDownloadTasks,
           let entry = pendingDownloadTaskURLs.popFirst() {
            let completion = entry.value
            let url = entry.key
            let downloadTask = KingfisherManager.shared.retrieveImage(with: url, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                // Update download progress
            }, downloadTaskUpdated: { task in
                // Download task update
                
            }, completionHandler: { result in
                defer {
                    self.downloadTasks.removeValue(forKey: url)
                    self.continuePendingDownloadTasks()
                }
                do {
                    let image = try result.get().image
                    completion(image, nil)
                } catch let error {
                    completion(nil, error)
                }
            })
            
            downloadTasks[url] = downloadTask
        }
        
        refreshDownloadTasks()
    }
    
    private func refreshDownloadTasks() {
        for entry in downloadTasks {
            if entry.value == nil {
                downloadTasks.removeValue(forKey: entry.key)
            }
        }
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
        metadata.contentType = "image/jpeg"

        let thumbnailId = imageId.replacingOccurrences(of: ".", with: "_thumbnail.").replacingOccurrences(of: ".mov", with: ".jpeg")
        
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
