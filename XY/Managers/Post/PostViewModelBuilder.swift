//
//  PostViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 19/02/2021.
//

import UIKit

final class PostViewModelBuilder {
    static func build(from model: PostModel, completion: @escaping(NewPostViewModel?) -> Void) {
        
        var profileId: String?
        var profileImage: UIImage?
        var nickname: String?
        var postImage: UIImage?
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        
        ProfileManager.shared.fetchProfile(userId: model.userId) { (result) in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let profileModel):
                nickname = profileModel.nickname
                profileId = profileModel.profileId
                group.enter()
                
                ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                    defer {
                        group.leave()
                    }
                    if let profileViewModel = profileViewModel {
                        profileImage = profileViewModel.profileImage
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
        StorageManager.shared.downloadImage(withContainerId: model.id, withImageId: model.images.first!) { (result) in
            defer {
                group.leave()
            }
            switch result {
            case .success(let image):
                postImage = image
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            let postViewModel = NewPostViewModel(
                id: model.id,
                nickname: nickname ?? "",
                timestamp: model.timestamp,
                content: model.content,
                profileId: profileId ?? "",
                profileImage: profileImage,
                image: postImage
            )
            completion(postViewModel)
        }))
    }
}
