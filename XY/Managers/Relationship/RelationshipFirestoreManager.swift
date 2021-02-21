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
    
    public func follow(otherId: String, completion: @escaping(Relationship?) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships)
            .whereField("\(FirebaseKeys.RelationshipKeys.users).\(userId)", in: [true, false])
            .whereField("\(FirebaseKeys.RelationshipKeys.users).\(otherId)", isEqualTo: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else if let querySnapshot = querySnapshot {
                    if let snapshot = querySnapshot.documents.first {
                        let data = snapshot.data()
                        var relationshipModel = Relationship(data, id: snapshot.documentID)
                        
                        // Follow back
                        relationshipModel.type = .friends
                        
                        let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships).document(snapshot.documentID)
                        document.setData(relationshipModel.toData(), merge: true) { error in
                            if let error = error {
                                print(error)
                            }
                        }
                        
                        completion(relationshipModel)
                    } else {
                        // Follow
                        let newDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships).document()
                        let relationshipModel = Relationship(user1ID: userId, user2ID: otherId, type: .follow, id: newDocument.documentID)
                        
                        newDocument.setData(relationshipModel.toData(), merge: false) { error in
                            if let error = error {
                                print(error)
                            }
                        }
                        
                        completion(relationshipModel)
                    }
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
}
