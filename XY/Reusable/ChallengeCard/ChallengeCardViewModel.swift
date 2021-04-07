//
//  ChallengeCardViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

struct ChallengeCardViewModel {
    let image: UIImage
    let title: String
    let description: String
    let tag: ColorLabelViewModel?
    let timeLeftText: String?
    let isReceived: Bool
    let friendBubbles: [FriendBubbleViewModel]?
}

extension ChallengeCardViewModel {
    static var fakeData = [
        ChallengeCardViewModel(
            image: ThumbnailManager.shared.generateVideoThumbnail(url: Bundle.main.url(forResource: "video1", withExtension: "mov")!)!,
            title: "EatAPizza",
            description: "Eat a pizza for lunch today!",
            tag: ColorLabelViewModel(colorLabelText: "New", colorLabelColor: UIColor(0xCAF035)),
            timeLeftText: "6H left",
            isReceived: true,
            friendBubbles: FriendBubbleViewModel.generateFakeData()
        ),
        ChallengeCardViewModel(
            image: ThumbnailManager.shared.generateVideoThumbnail(url: Bundle.main.url(forResource: "video2", withExtension: "mov")!)!,
            title: "FastingChallenge",
            description: "Don't eat for 24h.",
            tag: ColorLabelViewModel(colorLabelText: "Sent to", colorLabelColor: UIColor(0xFF0062)),
            timeLeftText: nil,
            isReceived: false,
            friendBubbles: FriendBubbleViewModel.generateFakeData()
        ),
        ChallengeCardViewModel(
            image: ThumbnailManager.shared.generateVideoThumbnail(url: Bundle.main.url(forResource: "video3", withExtension: "mov")!)!,
            title: "FaceFears",
            description: "Today is a day to face your fears. Sit directly on the toilets of I3P.",
            tag: ColorLabelViewModel(colorLabelText: "Expiring", colorLabelColor: UIColor(0xC6C6C6)),
            timeLeftText: "1H left",
            isReceived: true,
            friendBubbles: FriendBubbleViewModel.generateFakeData()
        ),
        ChallengeCardViewModel(
            image: ThumbnailManager.shared.generateVideoThumbnail(url: Bundle.main.url(forResource: "video4", withExtension: "mov")!)!,
            title: "FaceFears",
            description: "Today is a day to face your fears. Sit directly on the toilets of I3P.",
            tag: nil,
            timeLeftText: "1H left",
            isReceived: true,
            friendBubbles: FriendBubbleViewModel.generateFakeData()
        )
    ]
}
