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
    
    func saveVideoForChallenge(temporaryURL: URL) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let homeDirectory = paths[0]
        
        var fileURL = homeDirectory.appendingPathComponent(UUID().uuidString)
        fileURL.appendPathExtension("mov")

        let urlData = NSData(contentsOf: temporaryURL)
        if urlData!.write(to: fileURL, atomically: true) {
            return fileURL
        } else {
            fatalError()
        }
    }
    
    func sendNewChallenge(challengeCard: ChallengeCardViewModel, to friendsList: [UserViewModel], completion: @escaping(() -> Void)) {
        let context = CoreDataManager.shared.mainContext
        let entity = ChallengeDataModel.entity()
        let newChallenge = ChallengeDataModel(entity: entity, insertInto: context)
        
        newChallenge.title = challengeCard.title
        newChallenge.challengeDescription = challengeCard.description
        newChallenge.completionStateValue = ChallengeCompletionState.sent.rawValue
        newChallenge.expiryTimestamp = Date().addingTimeInterval(TimeInterval.days(1))
        newChallenge.fileUrl = self.saveVideoForChallenge(temporaryURL: CreateChallengeManager.shared.videoUrl!)
        newChallenge.fromUser = ProfileDataManager.shared.ownProfileModel
        newChallenge.previewImage = challengeCard.image.pngData()
        
        let friendModels = friendsList.map({ FriendsDataManager.shared.getDataModel(for: $0)! })
        friendModels.forEach({ friendModel in
            context.insert(friendModel)
            newChallenge.addToSentTo(friendModel)
        })
        
        try? context.save()
        
        self.activeChallenges.append(newChallenge)
        NotificationCenter.default.post(Notification(name: .didLoadActiveChallenges))
    
        completion()
    }
    
    #if DEBUG
    
    func testLoadChallenge() {
        let mainContext = CoreDataManager.shared.mainContext
        
        let fetchRequest: NSFetchRequest<ChallengeDataModel> = ChallengeDataModel.fetchRequest()
        do {
            let results = try mainContext.fetch(fetchRequest)
            
            results.forEach({
                                if let sentTo = $0.sentTo {
                                    assert(sentTo.count == 0)
                                }
                
            }
            )
            
//            NotificationCenter.default.post(name: .didLoadActiveChallenges, object: nil)
        }
        catch {
            debugPrint(error)
        }
    }
    
    #endif
    
    func loadNewActiveChallenge() {
        if Int.random(in: 0...3) == 3 {
            for _ in 0...Int.random(in: 1...3) {
                activeChallenges.append(ChallengeDataModel.fakeChallenge())
            }
            
            NotificationCenter.default.post(Notification(name: .didReceiveChallenges))
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
    
    func loadChallengesFromStorage() {
        let mainContext = CoreDataManager.shared.mainContext
        
        let fetchRequest: NSFetchRequest<ChallengeDataModel> = ChallengeDataModel.fetchRequest()
        do {
            let results = try mainContext.fetch(fetchRequest)
            activeChallenges = results
            
            NotificationCenter.default.post(name: .didLoadActiveChallenges, object: nil)
        }
        catch {
            debugPrint(error)
        }
    }
}
