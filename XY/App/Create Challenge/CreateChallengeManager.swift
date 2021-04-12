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
    
    var friendsToChallengeList: [FriendBubbleViewModel]?
    
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
            image: image,
            title: title,
            description: description,
            tag: nil,
            timeLeftText: nil,
            isReceived: false,
            friendBubbles: friendsToChallengeList,
            senderProfile: FriendBubbleViewModel.generateFakeData().randomElement()
        )
    }
}
