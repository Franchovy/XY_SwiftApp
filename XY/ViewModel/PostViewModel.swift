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
    func didFetchProfileData(viewModel: PostViewModel)
    func didFetchProfileImage(viewModel: PostViewModel)
    func didFetchPostImages(viewModel: PostViewModel)
}

class PostViewModel {
    weak var delegate: PostViewModelDelegate?
    
    var data: PostModel
    
    var postId: String
    var nickname: String!
    var timestamp: Date
    var content: String
    var profileId: String!
    
    init (from data: PostModel) {
        // Set normal properties
        postId = data.id
        content = data.content
        timestamp = data.timestamp
        imageIds = data.images
        self.data = data
        
        // Fetch image(s)
        let storage = Storage.storage()
        for imageId in imageIds {
            
            ImageDownloaderHelper.shared.getFullURL(imageId: imageId) { imageUrl, error in
                guard let imageUrl = imageUrl, error == nil else {
                    print(error ?? "Error fetching image")
                    return
                }
                
                KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Update download progress
                }, downloadTaskUpdated: { task in
                    // Download task update
                }, completionHandler: { result in
                    do {
                        let image = try result.get().image
                        self.images = [image]
                        self.delegate?.didFetchPostImages(viewModel: self)
                    } catch let error {
                        print("Error fetching profile image: \(error)")
                    }
                })
                
            }
        }
        
        // Fetch profile image and profile data
        let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(data.userId)
        userDocument.getDocument() { document, error in
            if let error = error {
                print("Error fetching user data: \(error)")
            }
            
            if let documentData = document?.data() {
                // Get profile data
                let profileId = documentData[FirebaseKeys.UserKeys.profile] as! String
                // Save profile Id for navigating to profile
                self.profileId = profileId
                
                let profileDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileId)
                profileDoc.getDocument() { document, error in
                    if let error = error {
                        print("Error fetching profile data: \(error)")
                    }
                    if let documentData = document?.data() {
                        // Set Nickname
                        self.nickname = documentData[FirebaseKeys.ProfileKeys.nickname] as? String
                        self.delegate?.didFetchProfileData(viewModel: self)
                        // Set profileImageId
                        self.profileImageId = documentData[FirebaseKeys.ProfileKeys.profileImage] as? String
                    }
                }
            }
        }
    }
    
    var profileImageId: String? {
        didSet {
            guard let profileImageId = profileImageId else { return }

            ImageDownloaderHelper.shared.getFullURL(imageId: profileImageId) { imageUrl, error in
                if let error = error {
                    print("Error fetching image!")
                }
                guard let imageUrl = imageUrl else { return }
                
                KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                    // Update download progress
                }, downloadTaskUpdated: { task in
                    // Download task update
                }, completionHandler: { result in
                    do {
                        let image = try result.get().image
                        self.profileImage = image
                        self.delegate?.didFetchProfileImage(viewModel: self)
                    } catch let error {
                        print("Error fetching profile image: \(error)")
                    }
                })
            }
        }
    }
    
    var imageIds: [String]
    
    var profileImage: UIImage?
    var images: [UIImage] = []
    
    // MARK: - Public Methods
    
    func sendSwipeRight() {
        FirebaseFunctionsManager.shared.swipeRight(postId: postId)

    }
    
    func sendSwipeLeft() {
        FirebaseFunctionsManager.shared.swipeLeft(postId: postId)
    }
    
    func getTimestampString() -> String {
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
    }
}
