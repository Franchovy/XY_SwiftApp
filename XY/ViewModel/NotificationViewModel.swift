//
//  Notification.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import Foundation
import UIKit
import Kingfisher

protocol NotificationViewModelDelegate: AnyObject {
    func didFetchDisplayImage(index: Int, image: UIImage)
    func didFetchPreviewImage(index: Int, image: UIImage)
    func didFetchPostForHandler(index: Int, post: PostModel)
    func didFetchProfileData(index: Int, profile: ProfileModel)
    func didOpenProfile(profile: ProfileModel)
    func didOpenPost(post: PostModel)
}

class NotificationViewModel {
    weak var delegate: NotificationViewModelDelegate?
    
    var profileData: ProfileModel?
    var postData: PostModel?
    
    var notificationId: String
    
    var displayImage: UIImage?
    var previewImage: UIImage?
    var nickname: String?
    var text: String?
    var date: Date
    var type: NotificationType
    
    let objectType: ObjectType
    let model: Notification
    
    init(from model: Notification) {
        self.model = model
        notificationId = model.notificationId
        date = model.timestamp
        text = model.type.text.replacingOccurrences(of: "_", with: model.objectType.text)
        type = model.type
        objectType = model.objectType
    }
    
    func fetch(index: Int) {
        
        if type == .levelUp {
            if objectType == .user {
                fetchProfile(for: index, id: model.objectId)
            } else if objectType == .post {
                fetchPost(for: index, postId: model.objectId)
            } else if objectType == .viral {
                fetchViralData(for: index, viralId: model.objectId)
            }
        } else if type == .swipeLeft || type == .swipeRight {
            if let senderId = model.senderId {
                fetchProfile(for: index, id: senderId)
            }

            // Fetch Post data
            fetchPost(for: index, postId: model.objectId)
        }
    }
    
    //MARK: - Delegate functions
    
    func openPost() {
        if let postData = postData {
            delegate?.didOpenPost(post: postData)
        }
    }
    func openProfile() {
        if let profileData = profileData {
            delegate?.didOpenProfile(profile: profileData)
        }
    }
    
    //MARK: - Fetch methods
    
    private func fetchViralData(for index: Int, viralId: String) {
        ViralManager.shared.getViral(forId: viralId) { result in
            switch result {
            case .success(let viralData):
                // Fetch thumbnail
                StorageManager.shared.downloadThumbnail(withContainerId: viralId, withImageId: viralData.videoRef) { (result) in
                    switch result {
                    case .success(let image):
                        self.previewImage = image
                        self.delegate?.didFetchPreviewImage(index: index, image: image)
                    case .failure(let error):
                        print("Error fetching thumbnail for viral: \(error)")
                    }
                }
            case .failure(let error):
                print("Error fetching data for viral: \(error)")
            }
            
        }
    }
    
    private func fetchPost(for index: Int, postId: String) {
        // Fetch swiped post
        FirebaseDownload.getPost(for: model.objectId) { postData, error in
            guard let postData = postData, error == nil else {
                print(error ?? "Error fetching data for post: \(self.model.objectId)")
                return
            }
            
            // Set up segue action for post VC
            DispatchQueue.main.async {
                self.postData = postData
                self.delegate?.didFetchPostForHandler(index: index, post: postData)
            }
            
            // Fetch image for post
            guard let imageId = postData.images.first else {
                return
            }
            
            StorageManager.shared.downloadThumbnail(withContainerId: postId, withImageId: imageId) { (result) in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.previewImage = image
                        self.delegate?.didFetchPreviewImage(index: index, image: image)
                    }
                case .failure(let error):
                    // Backup: get image using normal imageId
                    StorageManager.shared.downloadImage(withContainerId: postId, withImageId: imageId) { (result) in
                        switch result {
                        case .success(let image):
                            DispatchQueue.main.async {
                                self.previewImage = image
                                self.delegate?.didFetchPreviewImage(index: index, image: image)
                            }
                        case .failure(let error):
                            print("Error fetching image for imageId: \(imageId) and postId: \(postId): \(error)")
                        }
                    }
                }
            }
        }
    }
    
    private func fetchProfile(for index: Int, id: String) {
        // Fetch swipe user profile
        FirebaseDownload.getProfileId(userId: id) { (profileId, error) in
            guard let profileId = profileId, error == nil else {
                print(error ?? "Error fetching profileId for user: \(self.model.senderId)")
                return
            }
            
            FirebaseDownload.getProfile(profileId: profileId) { (profileData, error) in
                guard let profileData = profileData, error == nil else {
                    print(error ?? "Error fetching profile for user: \(self.model.senderId)")
                    return
                }
                
                self.profileData = profileData
                self.nickname = profileData.nickname
                self.delegate?.didFetchProfileData(index: index, profile: profileData)
                
                
                ImageDownloaderHelper.shared.getFullURL(imageId: profileData.profileImageId) { imageUrl, error in
                    guard let imageUrl = imageUrl, error == nil else {
                        print(error ?? "Error fetching profileImage for user: \(self.model.senderId)")
                        return
                    }
                    
                    KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.cacheOriginalImage], progressBlock: { receivedSize, totalSize in
                        // Update download progress
                    }, downloadTaskUpdated: { task in
                        // Download task update
                    }, completionHandler: { result in
                        do {
                            let image = try result.get().image
                            DispatchQueue.main.async {
                                self.displayImage = image
                                self.delegate?.didFetchDisplayImage(index: index, image: image)
                            }
                        } catch let error {
                            print("Error fetching profile image: \(error)")
                        }
                    })
                }
            }
        }
    }
}
