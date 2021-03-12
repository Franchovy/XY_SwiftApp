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
                for challengeDoc in querySnapshot.documents {
                    let challengeModel = ChallengeModel(
                        id: challengeDoc.documentID,
                        title: challengeDoc.data()[FirebaseKeys.ChallengeKeys.title] as! String,
                        description: challengeDoc.data()[FirebaseKeys.ChallengeKeys.description] as! String,
                        creatorID: challengeDoc.data()[FirebaseKeys.ChallengeKeys.creatorID] as! String,
                        level: challengeDoc.data()[FirebaseKeys.ChallengeKeys.level] as! Int,
                        xp: challengeDoc.data()[FirebaseKeys.ChallengeKeys.xp] as! Int
                    )
                    
                    FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.challenges).document(challengeDoc.documentID)
                        .collection(FirebaseKeys.ChallengeKeys.CollectionPath.videos)
                        .order(by: FirebaseKeys.ChallengeKeys.VideoKeys.timestamp)
                        .limit(to: 1)
                        .getDocuments { (querySnapshot, error) in
                        if let querySnapshot = querySnapshot {
                            if let videoDoc = querySnapshot.documents.first {
                                let challengeVideoModel = ChallengeVideoModel(
                                    challengeID: challengeDoc.documentID,
                                    ID: videoDoc.documentID,
                                    videoRef: videoDoc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.videoRef] as! String,
                                    caption: videoDoc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.caption] as? String,
                                    creatorID: videoDoc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.creatorID] as! String,
                                    xp: videoDoc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.xp] as! Int,
                                    level: videoDoc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.level] as! Int,
                                    timestamp: (videoDoc.data()[FirebaseKeys.ChallengeKeys.VideoKeys.timestamp] as! Firebase.Timestamp).dateValue()
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
    
    func uploadChallengeVideo(videoUrl: URL, challengeID: String, completion: @escaping(String, String) -> Void) {
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
                        let videoRef = containerPath.appending("/\(videoID)")
                        
                        let newChallengeModel:[String: Any] = [
                            FirebaseKeys.ChallengeKeys.VideoKeys.challengeID: challengeID,
                            FirebaseKeys.ChallengeKeys.VideoKeys.videoRef: videoRef,
                            FirebaseKeys.ChallengeKeys.VideoKeys.creatorID: userID,
                            FirebaseKeys.ChallengeKeys.VideoKeys.level: 0,
                            FirebaseKeys.ChallengeKeys.VideoKeys.xp: 0,
                            FirebaseKeys.ChallengeKeys.VideoKeys.timestamp: FieldValue.serverTimestamp()
                        ]
                        
                        newChallengeDocument.setData(newChallengeModel) { error in
                            if let error = error {
                                print(error)
                            } else {
                                print("Uploaded challenge video!")
                                completion(newChallengeDocument.documentID, videoRef)
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
