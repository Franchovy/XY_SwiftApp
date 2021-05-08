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
    var status: [ String: String ]
    var creatorID: String
    var uploading: Bool
}

struct ChallengeSubmissionDocument: Codable {
    var creatorID: String
    var videoID: String
    var timestamp: Timestamp
}

struct UserDocument: Codable {
    var nickname: String
    var numFriends: Int
    var numChallenges: Int
    var profileImageID: String?
    var hidden: Bool?
}

extension UserDocument {
    enum CodingKeys: String, CodingKey {
        case nickname = "xyname"
        case numFriends = "numFriends"
        case numChallenges = "numChallenges"
        case profileImageID = "profileImageID"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nickname = try values.decode(String.self, forKey: .nickname)
        numChallenges = try values.decodeIfPresent(Int.self, forKey: .numChallenges) ?? 0
        numFriends = try values.decodeIfPresent(Int.self, forKey: .numFriends) ?? 0
        profileImageID = try values.decodeIfPresent(String.self, forKey: .profileImageID)
    }
}

struct NotificationDocument: Codable {
    var timestamp: Timestamp
    var type: String
    var fromUser: String
    var objectID: String
}

struct FriendshipDocument: Codable {
    var friendstatus: String
}

final class FirebaseFirestoreManager {
    
    // MARK: - Class Properties
    
    static let shared = FirebaseFirestoreManager()
    private init() { }
    
    let root:DocumentReference = FirestoreReferenceManager.root
    
    var listeners = [ListenerRegistration]()
    
    // MARK: - Enums
    
    enum FirestoreManagerError: Error {
        case friendshipStatusInvalid
        case unknownError
        case decodingError
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
    
    func setChallengeStatus(challengeModel: ChallengeDataModel, completion: @escaping(Error?) -> Void) {
        let data: [String: [String: String]] = ["status" : [ProfileDataManager.shared.ownID: challengeModel.completionStateValue!]]
        root.collection(FirebaseCollectionPath.challenges).document(challengeModel.firebaseID!)
            .setData(data, merge: true) { error in
                completion(error)
            }
    }
    
    func setChallengeUploadStatus(challengeModel: ChallengeDataModel, isUploading: Bool, completion: @escaping(Error?) -> Void) {
        root.collection(FirebaseCollectionPath.challenges).document(challengeModel.firebaseID!)
            .setData( [
                "uploading": isUploading
            ], merge: true) { error in
                completion(error)
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
    
    func setProfileData(profileImageID: String, completion: @escaping(Error?) -> Void) {
        let data = [
            UserDocument.CodingKeys.profileImageID.rawValue : profileImageID
        ]
        
        root.collection(FirebaseCollectionPath.users).document(ProfileDataManager.shared.ownID)
            .setData(data, merge: true) { error in
                completion(error)
            }
    }
    
    // MARK: - Download functions
    
    func listenForNewChallenges(completion: @escaping(Result<[ChallengeModel], Error>) -> Void) {
        
        let listener = root.collection(FirebaseCollectionPath.challenges)
            .whereField("memberIDs", arrayContains: ProfileDataManager.shared.ownID)
            .whereField("uploading", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = querySnapshot {
                    var documents = [ChallengeModel]()
                    
                    snapshot.documentChanges
                        .forEach { diff in
                        if (diff.type == .added) {
                            do {
                                if let challengeDocument = try? diff.document.decode(as: ChallengeDocument.self) {
                                    let model = ChallengeModel(
                                        title: challengeDocument.title,
                                        challengeDescription: challengeDocument.description,
                                        expiryTimestamp: challengeDocument.timestamp.dateValue().addingTimeInterval(TimeInterval.days(1)),
                                        firebaseID: diff.document.documentID,
                                        completionState: .received,
                                        fromUserFirebaseID: challengeDocument.creatorID,
                                        image: nil
                                    )
                                    
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
        
        listeners.append(listener)
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
                                completion(nil)
                            }
                        } catch let error {
                            completion(error)
                            return
                        }
                    }
                }
            }
    }
    
    func getChallengeStatus(for challengeModel: ChallengeDataModel, completion: @escaping(Result<[(String, ChallengeCompletionState)], Error>) -> Void) {
        guard let firebaseID = challengeModel.firebaseID else {
            return
        }
        
        root.collection(FirebaseCollectionPath.challenges).document(firebaseID)
            .getDocument { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    if let challengeModel = try? snapshot.decode(as: ChallengeDocument.self) {
                        
                        if challengeModel.status.contains(where: { ChallengeCompletionState(rawValue: $0.value) == nil }) {
                            completion(.failure(FirestoreManagerError.decodingError))
                        } else {
                            let result = challengeModel.status.map { ($0.key, ChallengeCompletionState(rawValue: $0.value)!) }
                            
                            completion(.success(result))
                        }
                    } else {
                        completion(.failure(FirestoreManagerError.decodingError))
                    }
                }
            }
    }
    
    func fetchAllNotifications(completion: @escaping(Result<[NotificationModel], Error>) -> Void) {
        
        root.collection(FirebaseCollectionPath.users).document(ProfileDataManager.shared.ownID).collection(FirebaseCollectionPath.notifications)
            .order(by: "timestamp", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let querySnapshot = querySnapshot {
                    let notifications: [NotificationModel] = querySnapshot.documents.map({ documentSnapshot in
                        if let document = try? documentSnapshot.decode(as: NotificationDocument.self, includingId: true),
                           let type = NotificationType(rawValue: document.type) {
                            return NotificationModel(
                                firebaseID: documentSnapshot.documentID,
                                fromUserFirebaseID: document.fromUser,
                                challengeFirebaseID: document.objectID,
                                timestamp: document.timestamp.dateValue(),
                                type: type
                            )
                        } else {
                            return nil
                        }
                    }).compactMap({ $0 })
                    
                    completion(.success(notifications))
                }
            }
    }
    
    func fetchAllProfiles(completion: @escaping(Result<[UserModel], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var friendModels = [UserModel]()
        
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
                    
                    if let userDocument = try? document.decode(as: UserDocument.self) {
                        
                        if userDocument.profileImageID == nil ||
                            (userDocument.hidden ?? false) {
                            continue
                        }
                        
                        dispatchGroup.enter()
                        self.fetchFrienshipStatus(forID: document.documentID) { friendshipStatus, error in
                            defer {
                                dispatchGroup.leave()
                            }
                            if let error = error {
                                print("Error fetching friendship status: \(error)")
                            } else if let friendshipStatus = friendshipStatus {
                                
                                let userModel = UserModel(
                                    nickname: userDocument.nickname,
                                    numFriends: userDocument.numFriends,
                                    numChallenges: userDocument.numChallenges,
                                    firebaseID: document.documentID,
                                    profileImageFirebaseID: userDocument.profileImageID,
                                    friendStatus: friendshipStatus
                                )
                                
                                friendModels.append(userModel)
                            }
                        }
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
    
    func listenToUpdatesForUser(withID userID: String, completion: @escaping(Result<UserDocument, Error>) -> Void) {
        let listener = root.collection("Users").document(userID).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot,
                      let userDocument = try? snapshot.decode(as: UserDocument.self)
            {
                completion(.success(userDocument))
            }
        }
        
        listeners.append(listener)
    }
    
    func fetchProfile(for profileId: String, completion: @escaping(Result<UserModel, Error>) -> Void) {
        
        let dispatchGroup = DispatchGroup()
        
        var friendshipStatus: FriendStatus!
        var documentID: String!
        var userDocument: UserDocument!
        
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
                        userDocument = try snapshot.decode(as: UserDocument.self)
                        documentID = snapshot.documentID
                        
                    } catch let error {
                        completion(.failure(error))
                    }
                }
            }
        
        dispatchGroup.notify(queue: .main) {
            if let userDocument = userDocument, let friendshipStatus = friendshipStatus {
                let userModel = UserModel(
                    nickname: userDocument.nickname,
                    numFriends: userDocument.numFriends,
                    numChallenges: userDocument.numChallenges,
                    firebaseID: documentID,
                    profileImageFirebaseID: userDocument.profileImageID,
                    friendStatus: friendshipStatus
                )
                
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
    
    func removeAllListeners() {
        listeners.forEach({ $0.remove() })
        listeners = []
    }
    
    func listenForFriendStatusUpdates(onUpdate: @escaping(String?, FriendStatus?, Error?) -> Void) {
        // Firebase listener
        let listener = root.collection(FirebaseCollectionPath.users).document(ProfileDataManager.shared.ownID)
            .collection(FirebaseCollectionPath.friendships).addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    onUpdate(nil, nil, error)
                } else if let querySnapshot = querySnapshot {
                    for documentChange in querySnapshot.documentChanges {
                        let document = documentChange.document
                        
                        do {
                            let friendStatus = try self.convertDocumentToFriendStatus(document: document)
                            onUpdate(document.documentID, friendStatus, nil)
                        } catch let error {
                            onUpdate(nil, nil, error)
                        }
                    }
                }
            }
        
        listeners.append(listener)
    }
    
    func setFriendshipStatus(for otherUser: UserDataModel, completion: @escaping(Error?) -> Void) {
        assert(otherUser.firebaseID != nil)
        assert(otherUser.friendStatus != nil)
        
        let otherID = otherUser.firebaseID!
        let ownID = ProfileDataManager.shared.ownID
        
        let ownStatus = FriendStatus(rawValue: otherUser.friendStatus!)!
        let otherDocumentFriendshipStatus:FriendStatus = {
            switch FriendStatus(rawValue: otherUser.friendStatus!)! {
            case .added:
                return .addedMe
            case .addedMe:
                return .added
            case .friend:
                return .friend
            case .none:
                return .none
        }
        }()
        
        let ownFriendshipStatus = FriendshipDocument(friendstatus: ownStatus.rawValue)
        let otherFriendshipStatus = FriendshipDocument(friendstatus: otherDocumentFriendshipStatus.rawValue)
        
        let dispatchGroup = DispatchGroup()
        
        do {
            let ownDocumentData = try FirestoreEncoder().encode(ownFriendshipStatus)
            
            dispatchGroup.enter()
            
            // Set friend status on own document
            root.collection(FirebaseCollectionPath.users).document(ownID)
                .collection(FirebaseCollectionPath.friendships).document(otherID)
                .setData(ownDocumentData, merge: true) { error in
                    defer {
                        dispatchGroup.leave()
                    }
                    completion(error)
                }
        } catch let error {
            completion(error)
        }
        
        do {
            let otherDocumentData = try FirestoreEncoder().encode(otherFriendshipStatus)
            
            dispatchGroup.enter()
            
            // Set friend status on other document
            root.collection(FirebaseCollectionPath.users).document(otherID)
                .collection(FirebaseCollectionPath.friendships).document(ownID)
                .setData(otherDocumentData) { error in
                    defer {
                        dispatchGroup.leave()
                    }
                    completion(error)
                }
        } catch let error {
            completion(error)
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
        var completionStatus: [String: String] = [:]
        sentToUsers.forEach({ completionStatus[$0] = ChallengeCompletionState.sent.rawValue })
        
        let documentObject = ChallengeDocument(
            description: model.challengeDescription!,
            title: model.title!,
            timestamp: Timestamp(),
            memberIDs: sentToUsers,
            status: completionStatus,
            creatorID: ProfileDataManager.shared.ownID,
            uploading: model.downloadUrl == nil
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
            numChallenges: Int(userModel.numChallenges),
            profileImageID: userModel.profileImageFirebaseID
        )
        
        do {
            return try FirebaseEncoder().encode(document) as? [String: Any]
        } catch let error {
            throw error
        }
    }
}
