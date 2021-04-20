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

// MARK: - Firebase Document Models

struct ChallengeDocument: Codable {
    var description: String
    var title: String
    var timestamp: Timestamp
    var memberIDs: [String]
    var creatorID: String
}

struct ChallengeSubmissionDocument: Codable {
    var creatorID: String
    var videoID: String
    var timestamp: Timestamp
}

struct UserDocument {
    var nickname: String
    var numFriends: Int
    var numChallenges: Int
}

extension UserDocument: Codable {
    enum CodingKeys: String, CodingKey {
        case nickname = "xyname"
        case numFriends = "numFriends"
        case numChallenges = "numChallenges"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nickname = try values.decode(String.self, forKey: .nickname)
        numChallenges = try values.decodeIfPresent(Int.self, forKey: .numChallenges) ?? 0
        numFriends = try values.decodeIfPresent(Int.self, forKey: .numFriends) ?? 0
    }
}

struct FriendshipDocument: Codable {
    var friendstatus: String
}

final class FirebaseFirestoreManager {
    
    // MARK: - Class Properties
    
    static let shared = FirebaseFirestoreManager()
    private init() { }
    
    let root:DocumentReference = FirestoreReferenceManager.root
    
    // MARK: - Enums
    
    enum FirestoreManagerError: Error {
        case friendshipStatusInvalid
        case unknownError
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
            completion(FirestoreManagerError.friendshipStatusInvalid)
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
            completion(FirestoreManagerError.friendshipStatusInvalid)
        }
    }
    
    func createProfile(userDataModel: UserDataModel, completion: @escaping((Error?) -> Void)) {
        assert(userDataModel.firebaseID != nil, "Please set firebaseID property to firebase Auth ID!")
        
        do {
            if let data = try convertUserToDocument(userModel: userDataModel) {
                root.collection(FirebaseCollectionPath.users).document(userDataModel.firebaseID!).setData(data, merge: true) { error in
                    completion(error)
                }
            } else {
                completion(FirestoreManagerError.unknownError)
            }
        } catch let error {
            completion(error)
        }
    }
    
    func deleteOwnProfile(idForVerificationPurposes ownID: String, completion: @escaping(Error?) -> Void) {
        assert(ProfileDataManager.shared.ownProfileModel != nil, "Please set firebaseID property to firebase Auth ID!")
        assert(ProfileDataManager.shared.ownID == ownID)
        
        root.collection(FirebaseCollectionPath.users).document().delete { (error) in
            completion(error)
        }
    }
    
    func setProfileData(nickname: String, completion: @escaping(Error?) -> Void) {
        let data = [
            UserDocument.CodingKeys.nickname.rawValue : nickname
        ]
        
        root.collection(FirebaseCollectionPath.users).document(ProfileDataManager.shared.ownID)
            .setData(data, merge: true) { error in
                completion(error)
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
    
    func fetchAllProfiles(completion: @escaping(Result<[UserDataModel], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var friendModels = [UserDataModel]()
        
        dispatchGroup.enter()
        
        root.collection(FirebaseCollectionPath.users)
            .getDocuments { (querySnapshot, error) in
            defer {
                dispatchGroup.leave()
            }
            if let error = error {
                completion(.failure(error))
            } else if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    if document.documentID == ProfileDataManager.shared.ownID {
                        // Skip self
                        continue
                    }
                    
                    if let userDocument = try? self.convertUserFromDocument(document: document) {
                        
                        dispatchGroup.enter()
                        self.fetchFrienshipStatus(forID: document.documentID) { friendshipStatus, error in
                            defer {
                                dispatchGroup.leave()
                            }
                            if let error = error {
                                print("Error fetching friendship status: \(error)")
                            } else if let friendshipStatus = friendshipStatus {
                                userDocument.friendStatus = friendshipStatus.rawValue
                            }
                        }
                        
                        friendModels.append(userDocument)
                    } else {
                        print("Could not convert data: \(document.data())")
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(friendModels))
        }
        
    }
    
    func fetchProfile(for profileId: String, completion: @escaping(Result<UserDataModel, Error>) -> Void) {
        
        let dispatchGroup = DispatchGroup()
        
        var friendshipStatus: FriendStatus!
        var userModel: UserDataModel!
        
        if profileId != ProfileDataManager.shared.ownID {
            dispatchGroup.enter()
            // Fetch friendship status
            fetchFrienshipStatus(forID: profileId) { (friendStatus, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let friendStatus = friendStatus {
                    friendshipStatus = friendStatus
                }
            }
        } else {
            friendshipStatus = FriendStatus.none
        }
        
        // Fetch user document
        dispatchGroup.enter()
        
        root.collection(FirebaseCollectionPath.users).document(profileId)
            .getDocument { snapshot, error in
                defer {
                    dispatchGroup.leave()
                }
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    do {
                        userModel = try self.convertUserFromDocument(document: snapshot)
                        
                    } catch let error {
                        completion(.failure(error))
                    }
                }
            }
        
        dispatchGroup.notify(queue: .main) {
            if let userModel = userModel, let friendshipStatus = friendshipStatus {
                userModel.friendStatus = friendshipStatus.rawValue
                
                completion(.success(userModel))
            } else {
                completion(.failure(FirestoreManagerError.unknownError))
            }
        }
    }
    
    func fetchFrienshipStatus(forID userID: String, completion: @escaping(FriendStatus?, Error?) -> Void) {
        root.collection(FirebaseCollectionPath.users).document(ProfileDataManager.shared.ownID).collection(FirebaseCollectionPath.friendships)
            .document(userID)
            .getDocument { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                } else if let snapshot = snapshot {
                    do {
                        let friendshipStatus = try self.convertDocumentToFriendStatus(document: snapshot)
                        completion(friendshipStatus, nil)
                    } catch let error {
                        completion(nil, error)
                    }
                }
            }
    }
    
    func getVideosForChallenge(model: ChallengeDataModel, completion: @escaping(Error?) -> Void) {
        assert(model.firebaseID != nil)
        assert(model.firebaseVideoID == nil)
        
        root.collection(FirebaseCollectionPath.challenges).document(model.firebaseID!)
            .collection(FirebaseCollectionPath.challengeSubmissions)
            .order(by: "timestamp", descending: false) // Order by last one first
            .limit(to: 1)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(error)
                } else if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        do {
                            if let submissionModel = try self.convertChallengeSubmissionFromDocument(document: document) {
                                model.firebaseVideoID = submissionModel.videoID
                                assert(model.fromUser?.firebaseID == submissionModel.creatorID)
                            }
                        } catch let error {
                            completion(error)
                            return
                        }
                    }
                }
            }
    }
    
    // MARK: - Coredata-Firestore Conversions
    
    private func createChallengeSubmissionDocument(model: ChallengeDataModel) -> [String: Any]? {
        
        let documentObject = ChallengeSubmissionDocument(
            creatorID: model.fromUser!.firebaseID!,
            videoID: model.firebaseVideoID!,
            timestamp: Timestamp()
        )
        
        do {
            return try FirestoreEncoder().encode(documentObject)
        } catch let error {
            print("Encoding error: \(error)")
            return nil
        }
    }
    
    private func convertChallengeToDocument(model: ChallengeDataModel) -> [String: Any]? {
        
        let sentToUsers = model.sentTo!.allObjects.map({ ($0 as! UserDataModel).firebaseID! })
        
        let documentObject = ChallengeDocument(
            description: model.challengeDescription!,
            title: model.title!,
            timestamp: Timestamp(),
            memberIDs: sentToUsers,
            creatorID: ProfileDataManager.shared.ownID
        )
        
        do {
            return try FirestoreEncoder().encode(documentObject) as [String: Any]
        } catch let error {
            print("Encoding error: \(error)")
            return nil
        }
    }
    
    private func convertChallengeFromDocument(document: DocumentSnapshot) throws -> ChallengeDataModel? {
        guard document.data() != nil else {
            return nil
        }
        
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
    }
    
    private func convertChallengeSubmissionFromDocument(document: DocumentSnapshot) throws -> ChallengeSubmissionDocument? {
        guard document.data() != nil else {
            return nil
        }
        
        return try document.decode(as: ChallengeSubmissionDocument.self, includingId: false)
    }
    
    private func convertChallengeSubmissionToDocument(model: ChallengeDataModel) throws -> ChallengeSubmissionDocument? {
        fatalError("Not implemented yet.")
    }
    
    private func convertUserFromDocument(document: DocumentSnapshot) throws -> UserDataModel? {
        guard document.data() != nil else {
            return nil
        }
        
        let documentObject = try document.decode(as: UserDocument.self, includingId: false)
        
        let context = CoreDataManager.shared.mainContext
        let entity = UserDataModel.entity()
        let model = UserDataModel(entity: entity, insertInto: context)
        
        // set model properties
        model.firebaseID = document.documentID
        model.nickname = documentObject.nickname
        model.numFriends = Int16(documentObject.numFriends)
        model.numChallenges = Int16(documentObject.numChallenges)
        
        return model
    }
    
    private func convertDocumentToFriendStatus(document: DocumentSnapshot) throws -> FriendStatus {
        if !document.exists {
            return FriendStatus.none
        }
        
        let documentObject = try document.decode(as: FriendshipDocument.self, includingId: false)
        let status = FriendStatus.init(rawValue: documentObject.friendstatus)
        
        if status != nil {
            return status!
        } else {
            throw FirestoreManagerError.friendshipStatusInvalid
        }
    }
    
    private func convertUserToDocument(userModel: UserDataModel) throws -> [String: Any]? {
        assert(userModel.nickname != nil)
        
        let document = UserDocument(
            nickname: userModel.nickname!,
            numFriends: Int(userModel.numFriends),
            numChallenges: Int(userModel.numChallenges)
        )
        
        do {
            return try FirebaseEncoder().encode(document) as? [String: Any]
        } catch let error {
            throw error
        }
    }
}
