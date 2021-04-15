//
//  ChallengeDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 13/04/2021.
//

import Foundation
import CoreData
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
        if Int.random(in: 0...3) == 3 {
            for _ in 0...Int.random(in: 1...3) {
                activeChallenges.append(ChallengeDataModel.fakeChallenge())
            }
            
            NotificationCenter.default.post(Notification(name: .didLoadActiveChallenges))
        }
    }
    
    func updateChallengeState(challengeViewModel: ChallengeCardViewModel, newState: ChallengeCompletionState) {
        print("Updated challenge \"\(challengeViewModel.title)\" state: \(newState)")
        if let index = activeChallenges.firstIndex(where: { $0.title == challengeViewModel.title }) {
            let challenge = activeChallenges[index]
            challenge.completionState = newState
            activeChallenges[index] = challenge
        }
        assert(activeChallenges.first(where: { $0.title == challengeViewModel.title })!.completionState == newState)
    }
    
    func savePersistent() {
        do {
            try CoreDataManager.shared.mainContext.save()
        } catch let error {
            print("Error saving context: \(error)")
        }
    }
    
    func loadChallengesFromStorage() {
        let mainContext = CoreDataManager.shared.mainContext
        
        let fetchRequest: NSFetchRequest<ChallengeDataModel> = ChallengeDataModel.fetchRequest()
        do {
            let results = try mainContext.fetch(fetchRequest)
            activeChallenges = results
        }
        catch {
            debugPrint(error)
        }
    }
}
