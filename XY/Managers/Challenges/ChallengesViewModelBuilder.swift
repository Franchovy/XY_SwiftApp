//
//  ChallengesViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import Foundation

final class ChallengesViewModelBuilder {
    static func build(from model: ChallengeVideoModel, challengeModel: ChallengeModel, completion: @escaping(ChallengeViewModel?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var videoURL: URL?
        var creatorProfile: ProfileModel?
        
        StorageManager.shared.downloadVideo(videoId: model.videoRef, containerId: model.ID) { (result) in
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
        
        dispatchGroup.notify(
            queue: .main,
            work: DispatchWorkItem(block: {
                guard let creatorProfile = creatorProfile, let videoURL = videoURL else {
                    completion(nil)
                    return
                }
                let challengeViewModel = ChallengeViewModel(
                    id: model.ID,
                    videoUrl: videoURL,
                    title: challengeModel.title,
                    description: challengeModel.description,
                    gradient: Global.xyGradient,
                    creator: creatorProfile,
                    timeInMinutes: 1.0
                )
                
                completion(challengeViewModel)
            })
        )
    }
}
