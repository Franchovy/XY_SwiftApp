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
    
    func getChallenges(completion: @escaping([ChallengeModel]?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.challenges).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                var models = [ChallengeModel]()
                
                for doc in querySnapshot.documents {
                    let challengeModel = ChallengeModel(
                        id: doc.documentID,
                        title: doc.data()[FirebaseKeys.ChallengeKeys.title] as! String,
                        description: doc.data()[FirebaseKeys.ChallengeKeys.description] as! String,
                        creatorID: doc.data()[FirebaseKeys.ChallengeKeys.creatorID] as! String,
                        videoRef: doc.data()[FirebaseKeys.ChallengeKeys.videoRef] as! String,
                        level: doc.data()[FirebaseKeys.ChallengeKeys.level] as! Int,
                        xp: doc.data()[FirebaseKeys.ChallengeKeys.xp] as! Int
                    )
                    
                    models.append(challengeModel)
                }
                
                completion(models)
            }
        }
    }
    
    func uploadChallenge(videoUrl: URL, completion: @escaping(Bool) -> Void) {
        let gifPhotos = ThumbnailManager.shared.generateVideoThumbnailImages(
            url: videoUrl,
            timestamps: [0,1,2,3]) { (images) in
            if let images = images {
                
            }
        }
    }
}
