//
//  ChallengesViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import Foundation

final class ChallengesViewModelBuilder {
    static func build(from model: ChallengeModel, completion: @escaping(ChallengeViewModel?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var videoURL: URL?
        var creatorProfile: ProfileModel?
        
        StorageManager.shared.downloadVideo(videoId: model.videoRef, containerId: model.id) { (result) in
            defer {
                dispatchGroup.leave()
            }
            
            switch result {
            case .success(let url):
                videoURL = url
            case .failure(let error):
                print(error)
            }
        }
        
        ProfileFirestoreManager.shared.getProfile(
            forProfileID: model.creatorID) { (profileModel) in
            defer {
                dispatchGroup.leave()
            }
            
            if let profileModel = profileModel {
                creatorProfile = profileModel
            }
        }
        return;
        dispatchGroup.notify(
            queue: .main,
            work: DispatchWorkItem(block: {
                guard let creatorProfile = creatorProfile, let videoURL = videoURL else {
                    completion(nil)
                    return
                }
                let challengeViewModel = ChallengeViewModel(
                    id: model.id,
                    videoUrl: videoURL,
                    title: model.title,
                    description: model.description,
                    gradient: Global.xyGradient,
                    creator: creatorProfile
                )
                
                completion(challengeViewModel)
            })
        )
    }
}
