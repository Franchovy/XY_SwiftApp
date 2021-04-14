//
//  ChallengeDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import Foundation
import UIKit

extension Notification.Name {
    static let didReceiveChallenges = Notification.Name("didReceiveChallenges")
    static let didLoadActiveChallenges = Notification.Name("didLoadActiveChallenges")
    static let didFinishSendingChallenge = Notification.Name("didFinishSendingChallenge")
}

final class ChallengeDataManager {
    static var shared = ChallengeDataManager()
    
    var activeChallenges: [ChallengeDataModel]
    
    private init() {
        activeChallenges = []
    }
    
    func loadNewActiveChallenge() {
        let newChallenge = ChallengeDataModel(
            fileUrl: Bundle.main.url(forResource: "video1", withExtension: "mov"),
            title: "ScreamChallenge",
            description: "Scream randomly somewhere. Get your friend to film it.",
            expireTimestamp: Date().addingTimeInterval(TimeInterval.days(1)),
            fromUser: UserDataModel(nickname: "bobby", profileImage: UIImage(named: "friend1")!.pngData()!),
            previewImage: UIImage(named: "challenge1")!.pngData()!,
            completionState: .received
        )
        
        activeChallenges.append(newChallenge)
        activeChallenges.append(newChallenge)
        activeChallenges.append(newChallenge)
        
        NotificationCenter.default.post(Notification(name: .didLoadActiveChallenges))
    }
    
    func updateChallengeState(challengeViewModel: ChallengeCardViewModel, newState: ChallengeCompletionState) {
        print("Updated challenge \"\(challengeViewModel.title)\" state: \(newState)")
        if let index = activeChallenges.firstIndex(where: { $0.title == challengeViewModel.title }) {
            var challenge = activeChallenges[index]
            challenge.completionState = newState
            activeChallenges[index] = challenge
        }
        assert(activeChallenges.first(where: { $0.title == challengeViewModel.title })!.completionState == newState)
    }
}
