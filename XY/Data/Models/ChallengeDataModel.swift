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
