//
//  RankingFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import Foundation


class RankingDatabaseManager {
    static var shared = RankingDatabaseManager()
    private init() { }
    
    
    
    func getRanking(for playerID: String, completion: @escaping(Int?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users)
            .order(by: FirebaseKeys.UserKeys.level, descending: true)
            .order(by: FirebaseKeys.UserKeys.xp, descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                    completion(nil)
                } else if let querySnapshot = querySnapshot {
                    let index = querySnapshot.documents.firstIndex(where: { $0.documentID == playerID })
                    if index != nil {
                        completion(index! + 1)
                    } else {
                        completion(nil)
                    }
                }
            }
    }
}
