//
//  CreateChallengeManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import Foundation

final class CreateChallengeManager {
    static var shared = CreateChallengeManager()
    
    var videoUrl: URL?
    var description: String?
    var title: String?
    var friendsToChallengeList: [FriendBubbleViewModel]?
    
    func isReadyToCreateCard() -> Bool {
        return videoUrl != nil && description != nil && title != nil
    }
    
    func getChallengeCardViewModel() -> ChallengeCardViewModel? {
        guard
            let videoUrl = videoUrl,
            let description = description,
            let title = title,
            let image = ThumbnailManager.shared.generateVideoThumbnail(url: videoUrl)
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
            friendBubbles: friendsToChallengeList
        )
    }
}
