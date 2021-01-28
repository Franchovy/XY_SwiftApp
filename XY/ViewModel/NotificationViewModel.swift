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
    var onSelect: (() -> Void)?
    
    let model: Notification
    
    init(from model: Notification) {
        self.model = model
        notificationId = model.notificationId
        date = model.timestamp
        text = model.type.text
    }
    
    func fetch(index: Int) {
        if model.type == .swipeRight {
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
                guard let imageId = postData.images?.first else {
                    return
                }
                
                ImageDownloaderHelper.shared.getFullURL(imageId: imageId) { imageUrl, error in
                    guard let imageUrl = imageUrl, error == nil else {
                        print(error ?? "Error fetching post preview image for post: \(self.model.objectId)")
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
                                self.previewImage = image
                                self.delegate?.didFetchPreviewImage(index: index, image: image)
                            }
                        } catch let error {
                            print("Error fetching profile image: \(error)")
                        }
                    })
                }
            }
            
            // Fetch swipe user profile
            FirebaseDownload.getProfileId(userId: model.senderId) { (profileId, error) in
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
}
