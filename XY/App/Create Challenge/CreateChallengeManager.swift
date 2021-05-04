//
//  CreateChallengeManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit
import AVFoundation

final class CreateChallengeManager {
    static var shared = CreateChallengeManager()
    
    var videoUrl: URL?
    
    var description: String?
    var title: String?
    var previewImage: UIImage?
    var previewTimestamp: Double = 1.0
    
    var friendsToChallengeList: [UserViewModel]?
    
    var acceptedChallenge: ChallengeCardViewModel?
    
    func setVideoUrl(url: URL) {
        videoUrl = url
        previewImage = ThumbnailManager.shared.generateVideoThumbnail(url: url)
    }
    
    func changePreviewImageTimestamp() {
        guard let videoUrl = videoUrl else {
            return
        }
        
        let asset = AVURLAsset(url: videoUrl)
        let durationInSeconds = asset.duration.seconds
        
        previewTimestamp += 1.0
        if previewTimestamp > durationInSeconds {
            previewTimestamp = 0
        }
        
        if let image = ThumbnailManager.shared.generateVideoThumbnail(url: videoUrl, timestamp: previewTimestamp) {
            previewImage = image
        }
    }
    
    func isReadyToCreateCard() -> Bool {
        return videoUrl != nil && description != nil && title != nil
    }
    
    func startUploadChallenge(preparingProgress: @escaping(Double) -> Void, preparingCompletion: @escaping(Error?) -> Void) {
        guard let viewModel = getChallengeCardViewModel(), let friendsList = friendsToChallengeList else {
            fatalError("Not all challenge fields have been configured!")
        }
        
        do {
            let challenge = try ChallengeDataManager.shared.saveChallenge(challengeCard: viewModel, to: friendsList)
            
            ChallengeDataManager.shared.uploadChallengeCard(challenge: challenge) { (progress) in
                preparingProgress(progress)
            } completion: { (error) in
                preparingCompletion(error)
                if error == nil {
                    ChallengeDataManager.shared.uploadChallengeVideo(challenge: challenge) { progress in
                        
                    } onComplete: { (error) in
                        
                    }
                }
            }
        } catch let error {
            preparingCompletion(error)
        }
    }
    
    func loadAcceptedChallenge(_ viewModel: ChallengeCardViewModel) {
        acceptedChallenge = viewModel
        
        description = viewModel.description
        title = viewModel.title
        previewImage = viewModel.image
    }
    
    func getChallengeCardViewModel() -> ChallengeCardViewModel? {
        guard
            let videoUrl = videoUrl,
            let description = description,
            let title = title,
            let image = previewImage
        else {
            return nil
        }
        
        return ChallengeCardViewModel(
            coreDataID: nil,
            image: image,
            title: title,
            description: description,
            tag: nil,
            timeLeftText: nil,
            isReceived: false,
            friendBubbles: friendsToChallengeList,
            senderProfile: ProfileDataManager.shared.ownProfileViewModel
        )
    }
}
