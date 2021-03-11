//
//  ChallengesFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import Foundation
import Firebase

final class ChallengesFirestoreManager {
    static var shared = ChallengesFirestoreManager()
    
    func getChallenges(completion: @escaping([(ChallengeModel, ChallengeVideoModel)]?) -> Void) {
        
        var returnData = [(ChallengeModel, ChallengeVideoModel)]()
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.challenges).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for doc in querySnapshot.documents {
                    let challengeModel = ChallengeModel(
                        id: doc.documentID,
                        title: doc.data()[FirebaseKeys.ChallengeKeys.title] as! String,
                        description: doc.data()[FirebaseKeys.ChallengeKeys.description] as! String,
                        creatorID: doc.data()[FirebaseKeys.ChallengeKeys.creatorID] as! String,
                        level: doc.data()[FirebaseKeys.ChallengeKeys.level] as! Int,
                        xp: doc.data()[FirebaseKeys.ChallengeKeys.xp] as! Int
                    )
                    
                    FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.challenges).document(doc.documentID)
                        .collection(FirebaseKeys.ChallengeKeys.CollectionPath.videos)
                        .order(by: FirebaseKeys.ChallengeKeys.VideoKeys.timestamp)
                        .limit(to: 1)
                        .getDocuments { (querySnapshot, error) in
                        if let querySnapshot = querySnapshot {
                            if let doc = querySnapshot.documents.first {
                                let challengeVideoModel = ChallengeVideoModel(
                                    id: doc.documentID,
                                    creatorID: doc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.creatorID] as! String,
                                    videoRef: doc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.videoRef] as! String,
                                    creatorID: doc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.creatorID] as! String,
                                    level: doc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.level] as! Int,
                                    xp: doc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.xp] as! Int
                                )
                                
                                returnData.append((challengeModel, challengeVideoModel))
                            }
                            
                            completion(returnData)
                        }
                    }
                }
            }
        }
    }
    
    func createChallenge(title: String, description: String, completion: @escaping(String) -> Void) {
        guard let userID = AuthManager.shared.userId else {
            return
        }
        
        let newChallengeDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.challenges)
            .document()
        let newChallengeData:[String:Any] = [
            FirebaseKeys.ChallengeKeys.title: title,
            FirebaseKeys.ChallengeKeys.description: description,
            FirebaseKeys.ChallengeKeys.xp: 0,
            FirebaseKeys.ChallengeKeys.level: 0,
            FirebaseKeys.ChallengeKeys.creatorID: userID
        ]
        newChallengeDocument.setData(newChallengeData) { error in
            if let error = error {
                print(error)
            } else {
                completion(newChallengeDocument.documentID)
            }
        }
    }
    
    func uploadChallengeVideo(videoUrl: URL, challengeID: String, completion: @escaping(Bool) -> Void) {
        guard let userID = AuthManager.shared.userId else {
            return
        }
        
        let newChallengeDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.challenges)
            .document(challengeID)
            .collection(FirebaseKeys.ChallengeKeys.CollectionPath.videos)
            .document()
        let containerPath = "\(challengeID)/\(newChallengeDocument.documentID)"
        
        let thumbnail = ThumbnailManager.shared.generateVideoThumbnailImages(
            url: videoUrl,
            timestamps: [1]) { (images) in
            if let images = images {
                StorageManager.shared.uploadVideo(
                    from: videoUrl,
                    withThumbnail: images.first!,
                    withContainer: containerPath) { (result) in
                    switch result {
                    case .success(let videoID):
                        let newChallengeModel:[String: Any] = [
                            FirebaseKeys.ChallengeKeys.VideoKeys.challengeID: challengeID,
                            FirebaseKeys.ChallengeKeys.VideoKeys.videoRef: containerPath.appending("/\(videoID)"),
                            FirebaseKeys.ChallengeKeys.VideoKeys.creatorID: userID,
                            FirebaseKeys.ChallengeKeys.VideoKeys.level: 0,
                            FirebaseKeys.ChallengeKeys.VideoKeys.xp: 0,
                            FirebaseKeys.ChallengeKeys.VideoKeys.timestamp: FieldValue.serverTimestamp()
                        ]
                        
                        newChallengeDocument.setData(newChallengeModel) { error in
                            if let error = error {
                                print(error)
                                completion(false)
                            } else {
                                print("Uploaded challenge video!")
                                completion(true)
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
