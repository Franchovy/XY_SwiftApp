//
//  VideoFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import Foundation
import FirebaseFirestore

class VideoFirestoreManager {
    static let shared = VideoFirestoreManager()
    private init() { }
    
    func fetchVideos(completion: @escaping([VideoModel]?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.virals).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
                completion(nil)
            } else if let querySnapshot = querySnapshot {
                
                let videoModels = querySnapshot.documents.map { (doc) in
                    VideoModel(
                        id: doc.documentID,
                        videoRef: doc.data()[FirebaseKeys.ViralKeys.videoRef] as! String,
                        caption: doc.data()[FirebaseKeys.ViralKeys.caption] as! String,
                        profileId: doc.data()[FirebaseKeys.ViralKeys.profileId] as! String,
                        level: doc.data()[FirebaseKeys.ViralKeys.level] as! Int,
                        xp: doc.data()[FirebaseKeys.ViralKeys.xp] as! Int
                    )
                }
                
                completion(videoModels)
            }
        }
    }
    
}
