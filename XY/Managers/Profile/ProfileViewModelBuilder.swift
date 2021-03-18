//
//  ProfileViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import UIKit

final class ProfileViewModelBuilder {
    
    static func build(with profileModel: ProfileModel, withUserModel userModel: UserModel? = nil, fetchingProfileImage: Bool = true, fetchingCoverImage: Bool = true, completion: @escaping(NewProfileViewModel?) -> Void) {
        var profileImage: UIImage?
        var coverImage: UIImage?
        var relationship: Relationship?
        var userModel = userModel
        let group = DispatchGroup()
        
        if fetchingProfileImage {
            group.enter()
            
            FirebaseDownload.getImage(imageId: profileModel.profileImageId) { (image, error) in
                defer {
                    group.leave()
                }
                if let error = error {
                    print(error)
                } else if let image = image {
                    print("Fetched profile image")
                    profileImage = image
                }
            }
        }
        
        if fetchingCoverImage {
            group.enter()

            FirebaseDownload.getImage(imageId: profileModel.coverImageId) { (image, error) in
                defer {
                    group.leave()
                }
                if let error = error {
                    print(error)
                } else if let image = image {
                    coverImage = image
                }
            }
        }
        
        // Get user model from profile
        if userModel == nil {
            group.enter()
            FirebaseDownload.getOwnerUser(forProfileId: profileModel.profileId) { (userId, error) in
                defer {
                    group.leave()
                }
                if let error = error {
                    print(error)
                } else if let userId = userId {
                    group.enter()
                    group.enter()
                    
                    // Get relationship type
                    RelationshipFirestoreManager.shared.getRelationship(with: userId) { (result) in
                        defer {
                            group.leave()
                        }
                        switch result {
                        case .success(let model):
                            print("Fetched relationship")
                            
                            relationship = model
                        case .failure(let error):
                            print(error)
                        }
                    }
                    
                    // Get user model
                    UserFirestoreManager.getUser(with: userId) { (result) in
                        defer {
                            group.leave()
                        }
                        switch result {
                        case .success(let model):
                            print("Fetched user model")
                            
                            userModel = model
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        } else if let userModel = userModel {
            // Get relationship type
            RelationshipFirestoreManager.shared.getRelationship(with: userModel.id) { (result) in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let model):
                    print("Fetched relationship")
                    
                    relationship = model
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            
            let viewModel = NewProfileViewModel(
                nickname: profileModel.nickname,
                relationshipType: relationship?.toRelationshipToSelfType() ?? .none,
                numFollowers: profileModel.followers,
                numFollowing: profileModel.following,
                numSwipeRights: profileModel.swipeRights,
                website: profileModel.website,
                caption: profileModel.caption,
                profileImage: profileImage,
                coverImage: coverImage,
                xp: userModel?.xp ?? profileModel.xp,
                level: userModel?.level ?? profileModel.level,
                xyname: userModel?.xyname ?? "",
                userId: userModel?.id ?? "",
                profileId: profileModel.profileId
            )
            completion(viewModel)
        }))
    }
}
