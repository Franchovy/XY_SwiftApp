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
    case uploading
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
            coreDataID: id,
            image: previewImage != nil ? UIImage(data: previewImage!)! : nil,
            title: title!,
            description: challengeDescription!,
            tag: tagFromChallenge(),
            timeLeftText: expiryTimestamp != nil ? "\(expiryTimestamp!.hoursFromNow())H" : "",
            isReceived: !sentByYou(),
            friendBubbles: getSentToBubbles(),
            senderProfile: fromUser?.toViewModel()
        )
    }
    
    func sentByYou() -> Bool {
        if let nickname = fromUser!.nickname, nickname == ProfileDataManager.shared.nickname {
            return true
        } else {
            return false
        }
    }
    
    func getSentToBubbles() -> [UserViewModel]? {
        if let sentTo = sentTo, let models = sentTo.allObjects as? [UserDataModel] {
            return models.map({ $0.toViewModel() })
        } else {
            return nil
        }
    }
    
    func tagFromChallenge() -> ColorLabelViewModel? {
        guard let expiryTimestamp = expiryTimestamp else {
            return nil
        }
        
        if sentByYou() {
            return ColorLabelViewModel.sentTo
        } else if expiryTimestamp.hoursFromNow() < 2 {
            return ColorLabelViewModel.expiring
        } else if expiryTimestamp.hoursFromNow() > 22 {
            return ColorLabelViewModel.new
        } else {
            return nil
        }
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
