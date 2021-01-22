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
            website = profileData.website
            
            // Fetch profile image from id
            FirebaseDownload.getImage(imageId: profileData.profileImageId) { image, error in
                if let error = error {
                    print("Error fetching profile image for profile!")
                }
                if let image = image {
                    self.profileImage = image
                    self.delegate?.onProfileImageFetched(image)
                }
            }
            
            FirebaseDownload.getImage(imageId: profileData.coverImageId) { image, error in
                if let error = error {
                    print("Error fetching cover image for profile!")
                }
                if let image = image {
                    self.coverImage = image
                    self.delegate?.onCoverImageFetched(image)
                }
            }
        }
    }
    
    var nickname: String!
    var xyname: String!
    var numFollowers: Int!
    var numFollowing: Int!
    var website: String!
    var level: Int!
    var caption: String!
    var profileImage: UIImage?
    var coverImage: UIImage?
    
    init(profileId: String) {
        // Fetch profile data
        
        FirebaseDownload.getProfile(profileId: profileId) {profileData, error in
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
    
    func sendEditUpdate() {
        // Sends update to firebase for current values
        
        FirebaseUpload.editProfileInfo(profileData: profileData) { result in
            switch result {
            case .success():
                print("Successfully edited profile.")
            case .failure(let error):
                print("Error editing profile caption: \(error)")
            }
        }
    }
    
    
}
