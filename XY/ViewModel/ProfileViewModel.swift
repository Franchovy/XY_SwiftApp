//
//  ProfileViewModel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation
import FirebaseStorage

protocol ProfileViewModelDelegate: NSObjectProtocol {
    func onXYNameFetched(_ xyname: String)
    func onProfileDataFetched(_ viewModel: ProfileViewModel)
    func onProfileImageFetched(_ image: UIImage)
    func onCoverImageFetched(_ image: UIImage)
    func onXpUpdate(_ model: XPModel)
    func setCoverPictureOpacity(_ opacity: CGFloat)
}

class ProfileViewModel {
    weak var delegate: ProfileViewModelDelegate?
    var profileData: ProfileModel! {
        didSet {
            nickname = profileData.nickname
            numFollowers = profileData.followers
            numFollowing = profileData.following
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
    var numFollowers: Int!
    var numFollowing: Int!
    var numSwipeRights: Int!
    var website: String!
    var caption: String!
    var profileImage: UIImage?
    var coverImage: UIImage?
    
    var xp: Int?
    var level: Int?
    
    var xyname: String?
    var userId: String?
    
    var profileId: String
    
    init(profileId: String, userId: String) {
        // Fetch profile data
        self.profileId = profileId
        self.userId = userId
        
        FirebaseDownload.getProfile(profileId: profileId) { profileData, error in
            if let error = error {
                print("Error fetching profile: \(error)")
            }
            if let profileData = profileData {
                // Set profile data
                self.profileData = profileData
                self.delegate?.onProfileDataFetched(self)
            }
        }
        
        // Fetch xyname
        let userDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId)
        
        userDoc.getDocument { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print(error ?? "Error fetching user document with id: \(userId)")
                return
            }
            
            guard let userData = snapshot.data() as? [String: Any], let xyname = userData[FirebaseKeys.UserKeys.xyname] as? String else {
                 return
            }
            self.xyname = "@\(xyname)"
            self.delegate?.onXYNameFetched("@\(xyname)")
        }
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
    
    public func updateXP(_ xpModel: XPModel) {
        level = xpModel.level
        xp = xpModel.xp
        
        delegate?.onXpUpdate(xpModel)
    }
    
    public func setOpacity(_ opacity: CGFloat) {
        delegate?.setCoverPictureOpacity(opacity)
    }
}
