//
//  UserFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import Foundation
import Firebase

final class UserFirestoreManager {
    static func getUser(with id: String, completion: @escaping(Result<UserModel, Error>) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(id).getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, let data = snapshot.data() {
                
                let userModel = UserModel(
                    id: id,
                    xyname: data[FirebaseKeys.UserKeys.xyname] as! String,
                    timestamp: (data[FirebaseKeys.UserKeys.timestamp] as! Firebase.Timestamp).dateValue(),
                    xp: data[FirebaseKeys.UserKeys.xp] as! Int,
                    level: data[FirebaseKeys.UserKeys.level] as! Int,
                    profileId: data[FirebaseKeys.UserKeys.profile] as! String,
                    hidden: data[FirebaseKeys.UserKeys.hidden] as? Bool,
                    fcmToken: data[FirebaseKeys.UserKeys.fcmToken] as? String
                )
                
                completion(.success(userModel))
            }
        }
    }
}
