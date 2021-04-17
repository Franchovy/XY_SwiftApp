//
//  FirebaseFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 16/04/2021.
//

import Foundation
import FirebaseFirestore
import CodableFirebase


extension Timestamp: TimestampType {}

final class FirebaseFirestoreManager {
    
    // MARK: - Class Properties
    
    static let shared = FirebaseFirestoreManager()
    private init() { }
    
    let root:DocumentReference = FirestoreReferenceManager.root
    
    // MARK: - Enums
    
    enum FirestoreManagerError: Error {
        case conversionError
    }
    
    // MARK: - Firebase Document Models
    
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
    
    // MARK: - Upload functions
    
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
    
    // MARK: - Download functions
    
    func fetchChallengeDocumentsFromFirestore(completion: @escaping(Result<[ChallengeDataModel], Error>) -> Void) {
        
        root.collection(FirebaseCollectionPath.challenges)
            .whereField("memberIDs", arrayContains: ProfileDataManager.shared.ownID)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = querySnapshot {
                    var documents = [ChallengeDataModel]()
                    
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            do {
                                if let model = try self.convertChallengeFromDocument(document: diff.document) {
                                    documents.append(model)
                                }
                            } catch let error {
                                print("Error decoding challenge document: \(error)")
                            }
                        }
                    }
                    
                    completion(.success(documents))
                }
            }
    }
    
    // MARK: - Coredata-Firestore Conversions
    
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
    
    func convertChallengeFromDocument(document: DocumentSnapshot) throws -> ChallengeDataModel? {
        guard let data = document.data() else {
            return nil
        }
        do {
            let documentObject = try document.decode(as: ChallengeDocument.self, includingId: false)
            
            let context = CoreDataManager.shared.mainContext
            let entity = ChallengeDataModel.entity()
            let model = ChallengeDataModel(entity: entity, insertInto: context)
            
            model.title = documentObject.title
            model.challengeDescription = documentObject.description
            model.expiryTimestamp = documentObject.timestamp.dateValue().addingTimeInterval(TimeInterval.days(1))
            model.firebaseID = document.documentID
            model.completionState = .received
            model.fromUser = FriendsDataManager.shared.getOrCreateUserWithFirestoreID(id: documentObject.creatorID)
            
            return model
        } catch let error {
            print("Decoding error: \(error)")
            throw FirestoreManagerError.conversionError
        }
    }
    
    
}
