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
            senderProfile: fromUser?.toViewModel(),
            completionState: completionState
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
        } else if completionState == .accepted {
            return ColorLabelViewModel.accepted
        } else if completionState == .rejected {
            return ColorLabelViewModel.rejected
        } else if completionState == .complete {
            return ColorLabelViewModel.complete
        } else {
            return nil
        }
    }
    
    /// Returns ideal video url based on current conditions
    func getVideoUrl() -> URL? {
        if let localFile = localFileName {
            let fileUrl = ChallengeDataManager.shared.getURLforLocalFile(filename: localFile)
            return fileUrl
        } else if NetworkConnectionManager.shared.currentConnectionSpeed < 1.5,
                  let downloadUrlSD = downloadUrlSD
        {
            return downloadUrlSD
        } else if NetworkConnectionManager.shared.currentConnectionSpeed < 5.0,
                  let downloadUrlHD = downloadUrlHD
        {
            return downloadUrlHD
        } else if let downloadUrl = downloadUrl {
            return downloadUrl
        } else {
            return nil
        }
    }
}
