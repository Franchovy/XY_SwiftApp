//
//  ProfileViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import UIKit

final class ProfileViewModelBuilder {
    static func build(with profileModel: ProfileModel, completion: @escaping(NewProfileViewModel?) -> Void) {
        var profileImage: UIImage?
        var coverImage: UIImage?
        var userModel: UserModel?
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        // Fetch profile Image
        FirebaseDownload.getImage(imageId: profileModel.profileImageId) { (image, error) in
            defer {
                group.leave()
            }
            if let error = error {
                print(error)
            } else if let image = image {
                profileImage = image
            }
        }
        // Fetch cover Image
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
        
        FirebaseDownload.getOwnerUser(forProfileId: profileModel.profileId) { (userId, error) in
            if let error = error {
                print(error)
                group.leave()
            } else if let userId = userId {
                UserFirestoreManager.getUser(with: userId) { (result) in
                    defer {
                        group.leave()
                    }
                    switch result {
                    case .success(let model):
                        userModel = model
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            
            let viewModel = NewProfileViewModel(
                nickname: profileModel.nickname,
                numFollowers: profileModel.followers,
                numFollowing: profileModel.following,
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