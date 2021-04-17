//
//  FirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 16/04/2021.
//

import Foundation
import FirebaseFirestore
import CodableFirebase


extension Timestamp: TimestampType {}

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() { }
    
    let root = FirestoreReferenceManager.root
    
    enum FirestoreManagerError: Error {
        case conversionError
    }
    
    struct ChallengeDocument: Codable {
        var description: String
        var title: String
        var timestamp: Timestamp
        var memberIDs: [String]
        var creatorID: String
    }
    
    struct ChallengeSubmission: Codable {
        var creatorID: String
        var videoID: String
        var timestamp: Timestamp
    }
    
    func uploadChallenge(model: ChallengeDataModel, completion: @escaping(Error?) -> Void) {
        assert(model.challengeDescription != nil)
        assert(model.title != nil)
        assert(model.firebaseID != nil)
        
        assert(model.sentTo != nil)
        assert(model.sentTo!.count > 0)
        
        if let data = convertChallengeToDocument(model: model) {
            let documentReference = root.collection(FirebaseCollectionPath.challenges).document(model.firebaseID!)
            
            documentReference.setData(data) { error in
                completion(error)
            }
        } else {
            completion(FirestoreManagerError.conversionError)
        }
    }
    
    func uploadChallengeSubmission(model: ChallengeDataModel, completion: @escaping(Error?) -> Void) {
        assert(model.fromUser != nil)
        assert(model.fromUser!.firebaseID != nil)
        assert(model.firebaseID != nil)
        assert(model.firebaseVideoID != nil)
        
        if let data = createChallengeSubmissionDocument(model: model) {
            let documentReference = root.collection(FirebaseCollectionPath.challenges).document(model.firebaseID!)
                .collection(FirebaseCollectionPath.challengeSubmissions).document(model.firebaseVideoID!)
            
            documentReference.setData(data) { error in
                completion(error)
            }
        } else {
            completion(FirestoreManagerError.conversionError)
        }
    }
    
    func createChallengeSubmissionDocument(model: ChallengeDataModel) -> [String: Any]? {
        
        let documentObject = ChallengeSubmission(
            creatorID: model.fromUser!.firebaseID!,
            videoID: model.firebaseVideoID!,
            timestamp: Timestamp()
        )
        
        do {
            return try FirestoreEncoder().encode(documentObject) as? [String: Any]
        } catch let error {
            print("Encoding error: \(error)")
            return nil
        }
    }
    
    func convertChallengeToDocument(model: ChallengeDataModel) -> [String: Any]? {
        
        let sentToUsers = model.sentTo!.allObjects.map({ ($0 as! UserDataModel).firebaseID! })
        
        let documentObject = ChallengeDocument(
            description: model.challengeDescription!,
            title: model.title!,
            timestamp: Timestamp(),
            memberIDs: sentToUsers,
            creatorID: ProfileDataManager.shared.ownID
        )
        
        do {
            return try FirestoreEncoder().encode(documentObject) as? [String: Any]
        } catch let error {
            print("Encoding error: \(error)")
            return nil
        }
    }
    
    func convertChallengeFromDocument(document: DocumentSnapshot) -> ChallengeDataModel? {
        // TODO
        return ChallengeDataModel()
    }
}
