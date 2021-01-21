//
//  PostViewModel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/01/2021.
//

import UIKit
import Firebase
import FirebaseStorage
import Kingfisher

protocol PostViewModelDelegate: NSObjectProtocol {
    func didFetchProfileData(xyname: String)
    func profileImageDownloadProgress(progress: Float)
    func didFetchProfileImage()
    func postImageDownloadProgress(progress: Float)
    func didFetchPostImages()
}

class PostViewModel {
    weak var delegate: PostViewModelDelegate?
    
    var data: PostModel? {
        didSet {
            guard let data = data else { return }
            
            // Set normal properties
            postId = data.id
            content = data.content
            timestamp = data.timestamp
            imageIds = data.images
            
            //TODO: Get profileData for userId
            
            let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(data.userId)
            userDocument.getDocument() { document, error in
                if let error = error {
                    print("Error fetching user data: \(error)")
                }
                
                if let documentData = document?.data() {
                    // Get profile data
                    let profileId = documentData[FirebaseKeys.UserKeys.profile] as! String
                    let profileDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileId)
                    profileDoc.getDocument() { document, error in
                        if let error = error {
                            print("Error fetching profile data: \(error)")
                        }
                        if let documentData = document?.data() {
                            // Set XYName
                            self.xyname = documentData[FirebaseKeys.ProfileKeys.nickname] as? String
                            self.delegate?.didFetchProfileData(xyname: self.xyname!)
                            // Set profileImageId
                            self.profileImageId = documentData[FirebaseKeys.ProfileKeys.profileImage] as? String
                        }
                    }
                }
            }
            
            
        }
    }
    
    var postId: String!
    var xyname: String!
    var timestamp: Date!
    var content: String!
    
    var profileImageId: String? {
        didSet {
            guard let profileImageId = profileImageId else { return }

            ImageDownloaderHelper.getFullURL(imageId: profileImageId) { imageUrl, error in
                if let error = error {
                    print("Error fetching image!")
                }
                guard let imageUrl = imageUrl else { fatalError() }
                
                //let processor = DownsamplingImageProcessor(size: imageView.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 20)
                //imageView.kf.indicatorType = .activity
                //print("Fetching image with url: \(imageUrl.absoluteString)")
                KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Update download progress
                }, downloadTaskUpdated: { task in
                    // Download task update
                }, completionHandler: { result in
                    do {
                        let image = try result.get().image
                        self.profileImage = image
                        self.delegate?.didFetchProfileImage()
                    } catch let error {
                        print("Error fetching profile image: \(error)")
                    }
                })
            }
        }
    }
    
    var imageIds: [String]? {
        didSet {
            guard let imageIds = imageIds else { return }

            let storage = Storage.storage()
            for imageId in imageIds {
                
                ImageDownloaderHelper.getFullURL(imageId: imageId) { imageUrl, error in
                    if let error = error {
                        print("Error fetching image!")
                    }
                    guard let imageUrl = imageUrl else { fatalError() }
                    
//                    if KingfisherManager.shared.cache.isCached(forKey: imageUrl) {
                    
//                    }
                    KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                        // Update download progress
                    }, downloadTaskUpdated: { task in
                        // Download task update
                    }, completionHandler: { result in
                        do {
                            let image = try result.get().image
                            self.images = [image]
                            self.delegate?.didFetchPostImages()
                        } catch let error {
                            print("Error fetching profile image: \(error)")
                        }
                    })
                    
                }
            }
        }
    }
    
    var profileImage: UIImage?
    var images: [UIImage] = []
    
    // MARK: - Public Methods
    
    func sendSwipeRight() {
        FirebaseFunctionsManager.shared.swipeRight(postId: postId)
        /*FirebaseUpload.sendSwipeRight(postId: postId) { result in
            switch result {
            case .success():
                // XP automatically reloads
                break
            case .failure(let error):
                print("Error sending swipe right transaction: \(error)")
            }
        }*/
    }
    
    func sendSwipeLeft() {
        FirebaseUpload.sendSwipeLeft(postId: postId) { result in
            switch result {
            case .success():
                // Flow automatically reloads
                break
            case .failure(let error):
                print("Error sending swipe left transaction: \(error)")
            }
        }
    }
    
    func getTimestampString() -> String {
        if let timestamp = timestamp {
            if -timestamp.timeIntervalSinceNow < TimeInterval(60 * 60) {
                // Less than an hour ago
                let minutesAgo = (-timestamp.timeIntervalSinceNow / 60).rounded()
                return "\(Int(minutesAgo)) minutes ago"
            } else if -timestamp.timeIntervalSinceNow < TimeInterval(24 * 60 * 60) {
                // Less than one day ago
                let hoursAgo = (-timestamp.timeIntervalSinceNow / 60 / 60).rounded()
                return "\(Int(hoursAgo)) hours ago"
            } else {
                // More than one day ago
                let daysAgo = (-timestamp.timeIntervalSinceNow / 60 / 60 / 24).rounded()
                return "\(Int(daysAgo)) days ago"
            }
        } else {
            return ""
        }
    }
}
