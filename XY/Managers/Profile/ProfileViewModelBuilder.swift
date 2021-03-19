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
        var ranking: Int?
        
        let group = DispatchGroup()
        
        if fetchingProfileImage {
            group.enter()
            StorageManager.shared.downloadImage(withImageId: profileModel.profileImageId) { (image, error) in
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

            StorageManager.shared.downloadImage(withImageId: profileModel.coverImageId) { (image, error) in
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
            UserFirestoreManager.shared.getUserWithProfileID(profileModel.profileId) { model in
                defer {
                    group.leave()
                }
                if let model = model {
                    userModel = model
                    
                    group.enter()
                    RelationshipFirestoreManager.shared.getRelationship(with: model.id) { (result) in
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
                    
                    group.enter()
                    RankingFirestoreManager.shared.getRanking(for: model.id) { (rankingNumber) in
                        defer {
                            group.leave()
                        }
                        if let rankingNumber = rankingNumber {
                            ranking = rankingNumber
                        }
                    }
                }
            }
        } else if let userModel = userModel {
            group.enter()
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
            
            group.enter()
            RankingFirestoreManager.shared.getRanking(for: userModel.id) { (rankingNumber) in
                defer {
                    group.leave()
                }
                if let rankingNumber = rankingNumber {
                    ranking = rankingNumber
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
                rank: ranking,
                userId: userModel?.id ?? "",
                profileId: profileModel.profileId
            )
            completion(viewModel)
        }))
    }
}
