//
//  Notification.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import Foundation
import UIKit

protocol NotificationViewModelDelegate: AnyObject {
    func didFetchDisplayImage(index: Int, image: UIImage)
    func didFetchPreviewImage(index: Int, image: UIImage)
    func didFetchPostForHandler(index: Int, post: PostModel)
    func didFetchText(index: Int, text: String)
}

class NotificationViewModel {
    weak var delegate: NotificationViewModelDelegate?
    
    var displayImage: UIImage?
    var previewImage: UIImage?
    var title: String
    var text: String?
    var onSelect: (() -> Void)?
    
    let model: Notification
    
    init(from model: Notification) {
        self.model = model
        title = model.type.title
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
                    self.delegate?.didFetchPostForHandler(index: index, post: postData)
                }
                
                // Fetch image for post
                guard let imageId = postData.images?.first else { return }
                FirebaseDownload.getImage(imageId: imageId) { (image, error) in
                    guard let image = image, error == nil else {
                        print(error ?? "Error fetching post preview image for post: \(self.model.objectId)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.previewImage = image
                        self.delegate?.didFetchPreviewImage(index: index, image: image)
                    }
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
                    // Fetch swipe user profile image
                    FirebaseDownload.getImage(imageId: profileData.profileImageId) { (profileImage, error) in
                        guard let profileImage = profileImage, error == nil else {
                            print(error ?? "Error fetching profileImage for user: \(self.model.senderId)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.displayImage = profileImage
                            self.delegate?.didFetchDisplayImage(index: index, image: profileImage)
                        }
                    }
                }
            }
        }
    }
}
