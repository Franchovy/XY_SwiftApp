//
//  UserFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import Foundation
import Firebase

final class UserFirestoreManager {
    static var shared = UserFirestoreManager()
    private init() { }
    
    func getUserWithProfileID(_ ID: String, completion: @escaping(UserModel?) -> Void) {
        let userDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users)
            .whereField(FirebaseKeys.UserKeys.profile, isEqualTo: ID).limit(to: 1)
        
        userDoc.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil)
            }
            if let querySnapshot = querySnapshot, let snapshot = querySnapshot.documents.first {
                if let userModel = self.userFromDocument(snapshot) {
                    completion(userModel)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func getUser(with id: String, completion: @escaping(Result<UserModel, Error>) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(id).getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                if let userModel = self.userFromDocument(snapshot) {
                    completion(.success(userModel))
                }
            }
        }
    }
    
    private func userFromDocument(_ doc: DocumentSnapshot) -> UserModel? {
        guard let data = doc.data() else {
            return nil
        }
        
        return UserModel(
            id: doc.documentID,
            xyname: data[FirebaseKeys.UserKeys.xyname] as! String,
            timestamp: (data[FirebaseKeys.UserKeys.timestamp] as! Firebase.Timestamp).dateValue(),
            xp: data[FirebaseKeys.UserKeys.xp] as! Int,
            level: data[FirebaseKeys.UserKeys.level] as! Int,
            profileId: data[FirebaseKeys.UserKeys.profile] as! String,
            hidden: data[FirebaseKeys.UserKeys.hidden] as? Bool,
            fcmToken: data[FirebaseKeys.UserKeys.fcmToken] as? String
        )
    }
}
