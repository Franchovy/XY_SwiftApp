//
//  ChallengesViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import Foundation

final class ChallengesViewModelBuilder {
    
    static func build(from challengeModel: ChallengeModel, completion: @escaping(ChallengeViewModel?) -> Void) {
        ProfileFirestoreManager.shared.getProfileID(forUserID: challengeModel.creatorID) { (profileID, error) in
            if let error = error {
                print(error)
            } else if let profileID = profileID {
                ProfileFirestoreManager.shared.getProfile(forProfileID: profileID) { (profileModel) in
                    if let profileModel = profileModel {
                        let challengeViewModel = ChallengeViewModel(
                            id: challengeModel.id,
                            title: challengeModel.title,
                            description: challengeModel.description,
                            creator: profileModel,
                            category: challengeModel.category,
                            level: 0,
                            xp: 0
                        )
                        
                        completion(challengeViewModel)
                    }
                    
                }
            }
        }
    }
    
    static func buildChallengeAndVideo(from model: ChallengeVideoModel, challengeModel: ChallengeModel, completion: @escaping((ChallengeViewModel, ChallengeVideoViewModel)?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var videoURL: URL?
        var creatorProfile: ProfileModel?
        
        StorageManager.shared.downloadVideo(videoId: model.videoRef, containerId: nil) { (result) in
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
        
        ProfileFirestoreManager.shared.getProfileID(forUserID: model.creatorID) { (profileID, error) in
            if let error = error {
                print(error)
            } else if let profileID = profileID {
                ProfileFirestoreManager.shared.getProfile(forProfileID: profileID) { (profileModel) in
                    defer {
                        dispatchGroup.leave()
                    }
                    if let profileModel = profileModel {
                        creatorProfile = profileModel
                    }
                }
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
                    id: challengeModel.id,
                    title: "#\(challengeModel.title)",
                    description: challengeModel.description,
                    creator: creatorProfile,
                    category: challengeModel.category,
                    level: 0,
                    xp: 0
                )
                
                let challengeVideoViewModel = ChallengeVideoViewModel(
                    id: model.ID,
                    videoUrl: videoURL,
                    title: "#\(challengeModel.title)",
                    description: challengeModel.description,
                    caption: model.caption,
                    gradient: challengeModel.category.getGradient(),
                    creator: creatorProfile
                )
                
                completion((challengeViewModel, challengeVideoViewModel))
            })
        )
    }
    
    static func buildChallengeVideo(from model: ChallengeVideoModel, challengeTitle: String, challengeDescription: String, completion: @escaping(ChallengeVideoViewModel?) -> Void) {
            
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var videoURL: URL?
        var creatorProfile: ProfileModel?
        
        StorageManager.shared.downloadVideo(videoId: model.videoRef, containerId: nil) { (result) in
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
        
        ProfileFirestoreManager.shared.getProfileID(forUserID: model.creatorID) { (profileID, error) in
            if let error = error {
                print(error)
            } else if let profileID = profileID {
                ProfileFirestoreManager.shared.getProfile(forProfileID: profileID) { (profileModel) in
                    defer {
                        dispatchGroup.leave()
                    }
                    if let profileModel = profileModel {
                        creatorProfile = profileModel
                    }
                }
            }
        }
        
        dispatchGroup.notify(
            queue: .main,
            work: DispatchWorkItem(block: {
                guard let creatorProfile = creatorProfile, let videoURL = videoURL else {
                    completion(nil)
                    return
                }
                let challengeViewModel = ChallengeVideoViewModel(
                    id: model.ID,
                    videoUrl: videoURL,
                    title: challengeTitle,
                    description: challengeDescription,
                    caption: model.caption,
                    gradient: Global.xyGradient,
                    creator: creatorProfile
                )
                
                completion(challengeViewModel)
            })
        )
    }
}
