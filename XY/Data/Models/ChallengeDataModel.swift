//
//  ChallengeDataModel.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import UIKit

extension ChallengeDataModel {
    var completionState: ChallengeCompletionState {
        get {
            return ChallengeCompletionState(rawValue: self.completionStateValue!)!
        }
        
        set {
            self.completionStateValue = newValue.rawValue
        }
    }
}

enum ChallengeCompletionState: String {
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
            image: UIImage(data: previewImage!)!,
            title: title!,
            description: challengeDescription!,
            tag: nil,
            timeLeftText: "\(expiryTimestamp!.hoursFromNow())H",
            isReceived: true,
            friendBubbles: nil,
            senderProfile: FriendBubbleViewModel.generateFakeData().first
        )
    }
}

#if DEBUG
extension ChallengeDataModel {
    static func fakeChallenge() -> ChallengeDataModel {
        let url = [
            Bundle.main.url(forResource: "video1", withExtension: "mov"),
            Bundle.main.url(forResource: "video2", withExtension: "mov"),
            Bundle.main.url(forResource: "video3", withExtension: "mov"),
            Bundle.main.url(forResource: "video4", withExtension: "mov"),
            Bundle.main.url(forResource: "video5", withExtension: "mov")
        ][Int.random(in: 0...4)]
        
        let context = CoreDataManager.shared.mainContext
        let entity = ChallengeDataModel.entity()
        let challengeModel = ChallengeDataModel(entity: entity, insertInto: context)
        
        challengeModel.fileUrl = url!
        challengeModel.title = "ScreamRandomly"
        challengeModel.challengeDescription = "Scream randomly somewhere in public. Get your friend to film it."
        challengeModel.expiryTimestamp = Date().addingTimeInterval(TimeInterval.days(1))
        challengeModel.fromUser = UserDataModel.fakeUser()
        challengeModel.previewImage = ThumbnailManager.shared.generateVideoThumbnail(url: url!)!.pngData()!
        challengeModel.completionState = .received
        
        return challengeModel
    }
}
#endif
