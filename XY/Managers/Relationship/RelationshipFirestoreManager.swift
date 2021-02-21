//
//  RelationshipFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 21/02/2021.
//

import Foundation
import Firebase

final class RelationshipFirestoreManager {
    static let shared = RelationshipFirestoreManager()
    private init() { }
    
    public func getRelationship(with otherUserID: String, completion: @escaping(Result<Relationship?, Error>) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        
        var error: Error?
        var relationshipModel: Relationship?
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships)
            .whereField("\(FirebaseKeys.RelationshipKeys.users).\(userId)", in: [true, false])
            .whereField("\(FirebaseKeys.RelationshipKeys.users).\(otherUserID)", isEqualTo: true)
            .getDocuments { (querySnapshot, err) in
                defer {
                    group.leave()
                }
                if let err = err {
                    error = err
                } else if let querySnapshot = querySnapshot {
                    if let snapshot = querySnapshot.documents.first {
                        let data = snapshot.data()
                        relationshipModel = Relationship(data, id: snapshot.documentID)
                    }
                }
            }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships)
            .whereField("\(FirebaseKeys.RelationshipKeys.users).\(userId)", isEqualTo: true)
            .whereField("\(FirebaseKeys.RelationshipKeys.users).\(otherUserID)", in: [true, false])
            .getDocuments { (querySnapshot, err) in
                defer {
                    group.leave()
                }
                if let err = err {
                    error = err
                } else if let querySnapshot = querySnapshot {
                    if let snapshot = querySnapshot.documents.first {
                        let data = snapshot.data()
                        relationshipModel = Relationship(data, id: snapshot.documentID)
                    }
                }
            }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            if relationshipModel != nil {
                completion(.success(relationshipModel))
            } else if error != nil {
                completion(.failure(error!))
            } else {
                completion(.success(nil))
            }
        }))
    }
    
    public func unfollow(otherId: String, completion: @escaping(Result<Relationship?, Error>) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        getRelationship(with: otherId) { (result) in
            switch result {
            case .success(let relationshipModel):
                if var relationshipModel = relationshipModel {
                    if relationshipModel.type == .follow {
                        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships).document(relationshipModel.id).delete { (error) in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(nil))
                            }
                        }
                    } else {
                        relationshipModel = Relationship(id: relationshipModel.id, type: .follow, user1ID: otherId, user2ID: userId)
                        
                        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships).document(relationshipModel.id).setData(relationshipModel.toData(), merge: true) { (error) in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(relationshipModel))
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        decrementFollowers(for: otherId)
        decrementFollowing(for: userId)
    }
    
    public func follow(otherId: String, completion: @escaping(Relationship?) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        getRelationship(with: otherId) { (result) in
            switch result {
            case .success(let relationshipModel):
                if var relationshipModel = relationshipModel {
                    relationshipModel.type = .friends
                    
                    let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships).document(relationshipModel.id)
                    document.setData(relationshipModel.toData(), merge: true) { error in
                        if let error = error {
                            print(error)
                        }
                    }
                    
                    completion(relationshipModel)
                } else {
                    let newDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships).document()
                    let relationshipModel = Relationship(user1ID: userId, user2ID: otherId, type: .follow, id: newDocument.documentID)
                    
                    newDocument.setData(relationshipModel.toData(), merge: false) { error in
                        if let error = error {
                            print(error)
                        }
                    }
                    
                    completion(relationshipModel)
                }
            case .failure(let error):
                print(error)
            }
        }
        
        incrementFollowers(for: otherId)
        incrementFollowing(for: userId)
    }
    
    private func incrementFollowers(for userId: String) {
        ProfileManager.shared.fetchProfile(userId: userId) { (result) in
            switch result {
            case .success(let profileModel):
                FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileModel.profileId)
                    .setData([ FirebaseKeys.ProfileKeys.followers : FieldValue.increment(Int64(1)) ], merge: true)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func incrementFollowing(for userId: String) {
        ProfileManager.shared.fetchProfile(userId: userId) { (result) in
            switch result {
            case .success(let profileModel):
                FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileModel.profileId)
                    .setData([ FirebaseKeys.ProfileKeys.following : FieldValue.increment(Int64(1)) ], merge: true)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func decrementFollowers(for userId: String) {
        ProfileManager.shared.fetchProfile(userId: userId) { (result) in
            switch result {
            case .success(let profileModel):
                FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileModel.profileId)
                    .setData([ FirebaseKeys.ProfileKeys.followers : FieldValue.increment(Int64(-1)) ], merge: true)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func decrementFollowing(for userId: String) {
        ProfileManager.shared.fetchProfile(userId: userId) { (result) in
            switch result {
            case .success(let profileModel):
                FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileModel.profileId)
                    .setData([ FirebaseKeys.ProfileKeys.following : FieldValue.increment(Int64(-1)) ], merge: true)
            case .failure(let error):
                print(error)
            }
        }
    }
}
