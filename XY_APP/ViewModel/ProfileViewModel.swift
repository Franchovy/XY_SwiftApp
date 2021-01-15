//
//  ProfileViewModel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation
import FirebaseStorage

protocol ProfileViewModelDelegate: NSObjectProtocol {
    func onProfileDataFetched(_ profileData: ProfileModel)
    func onProfileImageFetched(_ image: UIImage)
    func onCoverImageFetched(_ image: UIImage)
}

class ProfileViewModel {
    weak var delegate: ProfileViewModelDelegate?
    var profileData: ProfileModel! {
        didSet {
            nickname = profileData.nickname
            numFollowers = profileData.followers
            numFollowing = profileData.following
            level = profileData.level
            caption = profileData.caption
            
            // Fetch profile image from id
            FirebaseDownload.getImage(imageId: profileData.profileImageId) { image, error in
                if let error = error {
                    print("Error fetching profile image for profile!")
                }
                if let image = image {
                    self.delegate?.onProfileImageFetched(image)
                }
            }
            
            FirebaseDownload.getImage(imageId: profileData.coverImageId) { image, error in
                if let error = error {
                    print("Error fetching cover image for profile!")
                }
                if let image = image {
                    self.delegate?.onCoverImageFetched(image)
                }
            }
        }
    }
    
    var nickname: String!
    var numFollowers: Int!
    var numFollowing: Int!
    var level: Int!
    var caption: String!
    
    init(userId: String) {
        // Fetch profile data
        FirebaseDownload.getProfile(userId: userId) { profileData, error in
            if let error = error {
                print("Error fetching profile: \(error)")
            }
            if let profileData = profileData {
                // Set profile data
                self.profileData = profileData
                self.delegate?.onProfileDataFetched(profileData)
            }
        }
    }
    
    init(profileData: ProfileModel) {
        self.profileData = profileData
    }
}
