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

protocol ChallengeUploadListener {
    func uploadProgress(id: ObjectIdentifier, progressUpload: Double)
    func finishedUpload(id: ObjectIdentifier)
    func errorUpload(id: ObjectIdentifier, error: Error)
}

final class ChallengeDataManager {
    static var shared = ChallengeDataManager()
    
    var activeChallenges: [ChallengeDataModel]
    
    var listeners: [ObjectIdentifier : [ChallengeUploadListener]?] = [:]
    
    private init() {
        activeChallenges = []
    }
    
    func registerListener(for challengeID: ObjectIdentifier, listener: ChallengeUploadListener) {
        if listeners[challengeID] == nil {
            listeners[challengeID] = [listener]
        } else {
            listeners[challengeID]!?.append(listener)
        }
    }
    
    func removeListeners(for challengeID: ObjectIdentifier) {
        listeners.removeValue(forKey: challengeID)
    }
    
    func saveVideoForChallenge(temporaryURL: URL) -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let homeDirectory = paths[0]
        
        let fileName = UUID().uuidString.appending(".mov")
        let fileURL = homeDirectory.appendingPathComponent(fileName)
        
        let urlData = NSData(contentsOf: temporaryURL)
        if urlData!.write(to: fileURL, atomically: false) {
            return fileName
        } else {
            fatalError()
        }
    }
    
    func getURLforLocalFile(filename: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let homeDirectory = paths[0]
        
        return homeDirectory.appendingPathComponent(filename)
    }
    
    func getChallengeWithFirebaseID(_ firebaseID: String) -> ChallengeDataModel? {
        return activeChallenges.first(where: { $0.firebaseID == firebaseID })
    }
    
    func saveChallenge(challengeCard: ChallengeCardViewModel, to friendsList: [UserViewModel]) throws -> ChallengeDataModel {
        let context = CoreDataManager.shared.mainContext
        let entity = ChallengeDataModel.entity()
        let newChallenge = ChallengeDataModel(entity: entity, insertInto: context)
        
        newChallenge.title = challengeCard.title
        newChallenge.challengeDescription = challengeCard.description
        newChallenge.completionStateValue = ChallengeCompletionState.sent.rawValue
        newChallenge.expiryTimestamp = Date().addingTimeInterval(TimeInterval.days(1))
        newChallenge.localFileName = self.saveVideoForChallenge(temporaryURL: CreateChallengeManager.shared.videoUrl!)
        newChallenge.fromUser = ProfileDataManager.shared.ownProfileModel
        newChallenge.previewImage = challengeCard.image!.pngData()
        
        let friendModels = friendsList.map({ FriendsDataManager.shared.getDataModel(for: $0)! })
        friendModels.forEach({ friendModel in
            context.insert(friendModel)
            newChallenge.addToSentTo(friendModel)
        })
        
        try context.save()
        
        self.activeChallenges.append(newChallenge)
        NotificationCenter.default.post(Notification(name: .didLoadActiveChallenges))
        
        return newChallenge
    }
    
    func uploadChallengeCard(challenge: ChallengeDataModel, preparingProgress: @escaping(Double) -> Void, completion: @escaping(Error?) -> Void) {
        
        // Get video file
        assert(challenge.localFileName != nil)
        let fileUrl = getURLforLocalFile(filename: challenge.localFileName!)
        assert(FileManager.default.fileExists(atPath: fileUrl.path))
        
        // Get challenge info
        assert(challenge.title != nil)
        assert(challenge.challengeDescription != nil)
        assert(challenge.previewImage != nil)
        assert(challenge.fromUser != nil)
        assert(challenge.sentTo != nil)
        assert(challenge.sentTo!.count > 0)
        
        var imageUploadProgress = 0.0 {
            didSet {
                preparingProgress((firestoreTasksProgress + imageUploadProgress)/2)
            }
        }
        var firestoreTasksProgress = 0.0 {
            didSet {
                preparingProgress((firestoreTasksProgress + imageUploadProgress)/2)
            }
        }
        
        // Create challenge IDs
        let challengeID = UUID().uuidString
        let videoID = UUID().uuidString
        
        challenge.firebaseID = challengeID
        challenge.firebaseVideoID = videoID
        CoreDataManager.shared.save()
        
        let dispatchGroup = DispatchGroup()
        
        // Upload document to firestore
        dispatchGroup.enter()
        FirebaseFirestoreManager.shared.uploadChallenge(model: challenge) { error in
            defer {
                dispatchGroup.leave()
            }
            if let error = error {
                completion(error)
            }
            firestoreTasksProgress += 0.5
        }
        
        dispatchGroup.enter()
        // Upload video reference to firestore
        FirebaseFirestoreManager.shared.uploadChallengeSubmission(model: challenge) { error in
            defer {
                dispatchGroup.leave()
            }
            if let error = error {
                completion(error)
            }
            firestoreTasksProgress += 0.5
        }
        
        dispatchGroup.enter()
        // Upload previewImage to storage
        FirebaseStorageManager.shared.uploadImageToStorage(
            imageData: challenge.previewImage!,
            storagePath: FirebaseStoragePaths.challengePreviewImgPath(challengeId: challenge.firebaseID!)
        ) { (progress) in
            imageUploadProgress = progress
        } onComplete: { (result) in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success( _):
                imageUploadProgress = 1.0
            case .failure(let error):
                completion(error)
            }
        }
        
        dispatchGroup.notify(queue: .global(qos: .background)) {
            completion(nil)
        }
    }
    
    func isChallengeUploading(id: ObjectIdentifier) -> Bool {
        guard let challengeDataModel = activeChallenges.first(where: { $0.id == id }) else {
            return false
        }
        
        return challengeDataModel.sentByYou() && challengeDataModel.downloadUrl == nil
    }
    
    func uploadChallengeVideo(challengeDataModel: ChallengeDataModel, onProgress: @escaping(Double) -> Void, onComplete: @escaping(Error?) -> Void) {
        assert(challengeDataModel.localFileName != nil)
        
        guard let fileName = challengeDataModel.localFileName else {
            return
        }
        
        let fileUrl = getURLforLocalFile(filename: fileName)
              
        guard FileManager().fileExists(atPath: fileUrl.relativePath) else {
            return
        }
        
        // Upload video to storage
        FirebaseStorageManager.shared.uploadVideoToStorage(
            videoFileUrl: fileUrl,
            storagePath: FirebaseStoragePaths.challengeVideoPath(challengeId: challengeDataModel.firebaseID!, videoId: challengeDataModel.firebaseVideoID!)
        ) { (progress) in
            self.listeners[challengeDataModel.id]??.forEach({ $0.uploadProgress(id: challengeDataModel.id, progressUpload: progress) })
            onProgress(progress)
        } onComplete: { (result) in
            switch result {
            case .success(let result):
                FirebaseFirestoreManager.shared.setChallengeUploadStatus(challengeModel: challengeDataModel, isUploading: false) { (error) in
                    self.listeners[challengeDataModel.id]??.forEach({ $0.finishedUpload(id: challengeDataModel.id) })
                }
                
                self.getVideoDownloadURL(for: challengeDataModel) { (error) in
                    onComplete(error)
                }
            case .failure(let error):
                self.listeners[challengeDataModel.id]??.forEach({ $0.errorUpload(id: challengeDataModel.id, error: error) })
                onComplete(error)
            }
        }
    }
    
    func loadVideosForChallengeModel(for challengeDataModel: ChallengeDataModel, completion: @escaping((Error?) -> Void)) {
        // Get video IDs from firestore
        FirebaseFirestoreManager.shared.getVideosForChallenge(model: challengeDataModel) { error in
            if let error = error {
                completion(error)
            } else {
                assert(challengeDataModel.firebaseVideoID != nil)
                // Get download URL for video
                self.getVideoDownloadURL(for: challengeDataModel) { error in
                    completion(error)
                }
            }
        }
    }
    
    func getVideoDownloadURL(for challengeDataModel: ChallengeDataModel, completion: @escaping(Error?) -> Void) {
        FirebaseStorageManager.shared.getVideoDownloadUrl(
            from: FirebaseStoragePaths.challengeVideoPath(challengeId: challengeDataModel.firebaseID!, videoId: challengeDataModel.firebaseVideoID!)
        ) { (result) in
            switch result {
            case .success(let url):
                challengeDataModel.downloadUrl = url
                completion(nil)
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func setupChallengesListener() {
        // set up firebase listener
        FirebaseFirestoreManager.shared.listenForNewChallenges { (result) in
            switch result {
            case .success(let challengesReceived):
                let newChallenges = challengesReceived.filter({ (challengeDataModel) in
                            !self.activeChallenges.contains(where: { $0.firebaseID == challengeDataModel.firebaseID }) })
                            .filter({ return $0.expiryTimestamp > Date() })
                var newChallengeDataModels = [ChallengeDataModel]()
                
                if newChallenges.isEmpty { return }
                
                let dispatchGroup = DispatchGroup()
                
                newChallenges
                    .forEach { (challengeModel) in
                    
                    // Create new challenge object
                    let challengeDataModel = self.createChallenge(model: challengeModel)
                    newChallengeDataModels.append(challengeDataModel)
                        
                    // Fetch preview images
                    dispatchGroup.enter()
                    self.getChallengeImage(for: challengeDataModel) { error in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let error = error {
                            print("Error downloading preview images for challenge: \(error.localizedDescription)")
                        }
                    }
                    
                    // Get video download url
                    dispatchGroup.enter()
                    self.loadVideosForChallengeModel(for: challengeDataModel) { (error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let error = error {
                            print("Error fetching videos for challenge: \(error)")
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.activeChallenges.append(contentsOf: newChallengeDataModels)
                    
                    CoreDataManager.shared.save()
                    
                    // Update state on firebase as "received"
                    newChallengeDataModels.forEach({
                        if ($0.completionState == .sent) {
                            self.updateChallengeState(challengeID: $0.id, newState: .received)
                        }
                    })
                    
                    NotificationCenter.default.post(name: .didFinishDownloadingReceivedChallenges, object: nil)
                }
            case .failure(let error):
                print("Error fetching challenges: \(error.localizedDescription)")
            }
        }
    }
    
    func getChallengeImage(for challengeDataModel: ChallengeDataModel, completion: @escaping(Error?) -> Void) {
        FirebaseStorageManager.shared.downloadImage(
            from: FirebaseStoragePaths.challengePreviewImgPath(challengeId: challengeDataModel.firebaseID!))
        { progress in
            
        } completion: { result in
            switch result {
            case .success(let imageData):
                challengeDataModel.previewImage = imageData
                CoreDataManager.shared.save()
                
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func updateChallengeState(challengeID: ObjectIdentifier, newState: ChallengeCompletionState) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challengeID }) {
            
            let challenge = activeChallenges[index]
            challenge.completionState = newState
            activeChallenges[index] = challenge
            
            CoreDataManager.shared.save()
            
            FirebaseFirestoreManager.shared.setChallengeStatus(challengeModel: challenge) { error in
                if let error = error {
                    print("Error setting new status for challenge in firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully updated challenge state.")
                }
            }
        }
    }
    
    func expireOldChallenges() {
        var indexesToRemove = [Int]()
        
        for (index, challengeDataModel) in activeChallenges.enumerated() {
            if let expiry = challengeDataModel.expiryTimestamp, expiry < Date() {
                indexesToRemove.append(index)
                CoreDataManager.shared.mainContext.delete(challengeDataModel)
            }
        }
        
        activeChallenges.removeAll(where: { $0.expiryTimestamp ?? Date() < Date() })
    }
    
    func loadChallengesFromStorage() {
        let mainContext = CoreDataManager.shared.mainContext
        
        let fetchRequest: NSFetchRequest<ChallengeDataModel> = ChallengeDataModel.fetchRequest()
        do {
            let results = try mainContext.fetch(fetchRequest)
            activeChallenges = results
            
            activeChallenges.filter({$0.completionState == .sent}).forEach({$0.completionState = .received})
            expireOldChallenges()
            CoreDataManager.shared.save()
            
            // Verification check on received challenges
            let dispatchGroup = DispatchGroup()
            
            for challengeReceived in activeChallenges.filter( { !$0.sentByYou() }) {
                // check image
                if challengeReceived.previewImage == nil {
                    dispatchGroup.enter()
                    self.getChallengeImage(for: challengeReceived) { (error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let error = error {
                            print("Error fetching challenge image: \(error.localizedDescription)")
                        }
                    }
                }
                
                // check video link
                if challengeReceived.downloadUrl == nil {
                    dispatchGroup.enter()
                    self.loadVideosForChallengeModel(for: challengeReceived) { (error) in
                        defer{
                            dispatchGroup.leave()
                        }
                        if let error = error {
                            print("Error fetching video download link for challenge: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            // Verification check on sent challenges
            for challengeToUpload in activeChallenges.filter( { $0.sentByYou() && $0.downloadUrl == nil }) {
                
                if challengeToUpload.firebaseID == nil {
                    // Must upload challenge documents
                    continue
                }
                
                self.uploadChallengeCheck(challengeToUpload)
            
            }
            
            dispatchGroup.notify(queue: .main) {
                NotificationCenter.default.post(name: .didLoadActiveChallenges, object: nil)
            }
        }
        catch {
            debugPrint(error)
        }
    }
    
    func uploadChallengeCheck(_ challengeToUpload: ChallengeDataModel) {
        if challengeToUpload.downloadUrl == nil {
            FirebaseStorageManager.shared.getVideoDownloadUrl(
                from: FirebaseStoragePaths.challengeVideoPath(challengeId: challengeToUpload.firebaseID!, videoId: challengeToUpload.firebaseVideoID!)) { (result) in
                switch result {
                case .success(let url):
                    challengeToUpload.downloadUrl = url
                    CoreDataManager.shared.save()
                case .failure(let error):
                    
                    // Upload video
                    self.uploadChallengeVideo(challengeDataModel: challengeToUpload) { (progress) in
                        print("Progress uploading challenge video: \(progress)")
                    } onComplete: { (error) in
                        if let error = error {
                            print("Error uploading video for challenge: \(error.localizedDescription)")
                        } else {
                            FirebaseStorageManager.shared.getVideoDownloadUrl(
                                from: FirebaseStoragePaths.challengeVideoPath(challengeId: challengeToUpload.firebaseID!, videoId: challengeToUpload.firebaseVideoID!)) { (result) in
                                switch result {
                                case .success(let url):
                                    challengeToUpload.downloadUrl = url
                                    CoreDataManager.shared.save()
                                case .failure(let error):
                                    print("Error getting download url for challenge needing upload: \(error.localizedDescription)")
                                }
                            }
                            
                            FirebaseFirestoreManager.shared.setChallengeUploadStatus(challengeModel: challengeToUpload, isUploading: false) { (error) in
                                if let error = error {
                                    print("Error changing upload status for challenge: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getChallengeStatuses(for challengeID: ObjectIdentifier, completion: @escaping([(UserDataModel, ChallengeCompletionState)]) -> Void) {
        guard let challengeDataModel = activeChallenges.first(where: { $0.id == challengeID }) else {
            return
        }
        
        FirebaseFirestoreManager.shared.getChallengeStatus(for: challengeDataModel) { result in
            switch result {
            case .success(let statuses):
                let returnData: [(UserDataModel, ChallengeCompletionState)] = statuses.map { (userFirebaseID, status) in
                    if let user = FriendsDataManager.shared.getUserWithFirebaseID(userFirebaseID) {
                        return (user, status)
                    } else {
                        return nil
                    }
                }.compactMap { $0 }
                completion(returnData)
            case .failure(let error):
                print("Error decoding challenge status: \(error.localizedDescription)")
            }
            
        }
    }
    
    func createChallenge(model: ChallengeModel) -> ChallengeDataModel {
        let entity = ChallengeDataModel.entity()
        let context = CoreDataManager.shared.mainContext
        
        let challengeDataModel = ChallengeDataModel(entity: entity, insertInto: context)
        
        challengeDataModel.title = model.title
        challengeDataModel.challengeDescription = model.challengeDescription
        challengeDataModel.completionStateValue = model.completionState.rawValue
        challengeDataModel.expiryTimestamp = model.expiryTimestamp
        challengeDataModel.firebaseID = model.firebaseID
        
        let fetchRequest: NSFetchRequest<UserDataModel> = UserDataModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "firebaseID == %@", model.fromUserFirebaseID)
        
        guard let results = try? CoreDataManager.shared.mainContext.fetch(fetchRequest), let user = results.first else {
            fatalError("User not found")
        }
        
        challengeDataModel.fromUser = user
        
        return challengeDataModel
    }
}
