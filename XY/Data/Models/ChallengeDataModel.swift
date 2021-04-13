//
//  ChallengeDataModel.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit

struct ChallengeDataModel {
    let fileUrl: URL?
    let title: String
    let description: String
    let expireTimestamp: Date
    let fromUser: UserDataModel
    let previewImage: Data
    var completionState: ChallengeCompletionState
}

enum ChallengeCompletionState {
    case sent
    case received
    case rejected
    case accepted
    case complete
    case expired
}

extension ChallengeDataModel {
    func toCard() -> ChallengeCardViewModel {
        ChallengeCardViewModel(
            image: UIImage(data: previewImage)!,
            title: title,
            description: description,
            tag: nil,
            timeLeftText: "\(expireTimestamp.hoursFromNow())H",
            isReceived: true,
            friendBubbles: nil,
            senderProfile: FriendsDataManager.shared.getBubbleFromData(dataModel: fromUser)
        )
    }
}
