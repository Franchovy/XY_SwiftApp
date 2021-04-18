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
    static let didFinishDownloadingReceivedChallenges = Notification.Name("didReceiveChallenges")
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
    
    func uploadChallenge(challenge: ChallengeDataModel) {
//        DispatchQueue.global(qos: .background).async { // this messes up because of coredata multithreading sensitivity :(
            // Get video file
            assert(challenge.fileUrl != nil)
            assert(FileManager.default.fileExists(atPath: challenge.fileUrl!.path))
            let url = challenge.fileUrl!
            
            // Get challenge info
            assert(challenge.title != nil)
            assert(challenge.challengeDescription != nil)
            assert(challenge.previewImage != nil)
            assert(challenge.fromUser != nil)
            assert(challenge.sentTo != nil)
            assert(challenge.sentTo!.count > 0)
            
            // Create challenge IDs
            let challengeID = UUID().uuidString
            let videoID = UUID().uuidString
            
            challenge.firebaseID = challengeID
            challenge.firebaseVideoID = videoID
            
            // Upload document to firestore
            FirebaseFirestoreManager.shared.uploadChallenge(model: challenge) { error in
                if let error = error {
                    print("Error creating challenge in firestore: \(error)")
                }
            }
            
            // Upload video reference to firestore
            FirebaseFirestoreManager.shared.uploadChallengeSubmission(model: challenge) { error in
                if let error = error {
                    print("Error creating submission document in firestore: \(error)")
                }
            }
            
            // Upload previewImage to storage
            FirebaseStorageManager.shared.uploadImageToStorage(
                imageData: challenge.previewImage!,
                filename: challengeID.appending(".png"),
                containerName: challengeID
            ) { (progress) in
                print("Progress uploading image: \(progress)")
            } onComplete: { (result) in
                switch result {
                case .success(let _):
                    print("Successfully uploaded")
                case .failure(let error):
                    print("Failure to upload image: \(error)")
                }
            }
            
            // Upload video to storage
            FirebaseStorageManager.shared.uploadVideoToStorage(
                videoFileUrl: url,
                filename: videoID.appending(".mov"),
                containerName: challengeID
            ) { (progress) in
                print("Progress uploading video: \(progress)")
            } onComplete: { (result) in
                switch result {
                case .success(let _):
                    print("Successfully uploaded")
                case .failure(let error):
                    print("Failure to upload video: \(error)")
                }
            }
//        }
    }
    
    func fetchChallengeCards() {
        // Fetch challenges
        FirebaseFirestoreManager.shared.fetchChallengeDocumentsFromFirestore { (result) in
            switch result {
            case .success(let challengeModels):
                
                challengeModels.forEach { (challengeDataModel) in
                    // Fetch preview images
                    let imagePath = "\(challengeDataModel.firebaseID!)/\(challengeDataModel.firebaseID!)"
                    FirebaseStorageManager.shared.downloadImage(from: imagePath) { progress in
                        
                    } completion: { result in
                        switch result {
                        case .success(let imageData):
                            challengeDataModel.previewImage = imageData
                        case .failure(let error):
                            print("Error downloading preview images for challenge: \(error.localizedDescription)")
                        }
                    }
                    
                    // Download videos
                    FirebaseStorageManager.shared.getVideoDownloadUrl(from: "\(challengeDataModel.firebaseID!)/\(challengeDataModel.firebaseVideoID!)") { (result) in
                        switch result {
                        case .success(let url):
                            challengeDataModel.downloadUrl = url
                        case .failure(let error):
                            print("Error getting download link to video: \(error.localizedDescription)")
                        }
                    }
                    
                    NotificationCenter.default.post(name: .didFinishDownloadingReceivedChallenges, object: nil)
                }
            case .failure(let error):
                print("Error fetching challenges: \(error.localizedDescription)")
            }
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
