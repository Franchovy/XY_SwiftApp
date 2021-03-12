//
//  FlowAlgorithmManager.swift
//  XY
//
//  Created by Maxime Franchot on 14/02/2021.
//

import Foundation

final class FlowAlgorithmManager {
    static let shared = FlowAlgorithmManager()
    
    private init() {
        // Load previous flow data from userdefaults
        
    }
    
    var followingIDs = [String]()
    
    public func initialiseFollowing() {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.relationships)
            .whereField("\(FirebaseKeys.RelationshipKeys.users).\(userId)", isEqualTo: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else if let querySnapshot = querySnapshot {
                    for doc in querySnapshot.documents {
                        let members = doc.data()[FirebaseKeys.RelationshipKeys.users] as! [String:Bool]
                        
                        if let friendID = members.first(where: { $0.key != userId }) {
                            self.followingIDs.append(friendID.key)
                        }
                    }
                }
            }
    }
    
    public func getFlowFromFollowing(completion: @escaping([PostModel]?) -> Void) {
        // Random 10 from following
        var getFromFollowing = [String]()
        var followingIDsCopy = followingIDs
        for i in 0...9 {
            if followingIDsCopy.count == 0 {
                break
            }
            getFromFollowing.append(
                followingIDsCopy.remove(at: Int.random(in: 0...followingIDsCopy.count-1))
            )
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: true)
            .whereField(FirebaseKeys.PostKeys.author, in: getFromFollowing)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error)
                } else if let querySnapshot = querySnapshot {
                    
                    let models = querySnapshot.documents.compactMap { (doc) in
                        return PostModel(from: doc.data(), id: doc.documentID)
                    }
                    
                    completion(models)
                }
            }
    }
    
    
    var algorithmIndex = 1
    
    public func getFlow(completion: @escaping([PostModel]?) -> Void) {
        let previousSwipeLeftActions = ActionManager.shared.previousActions.filter({ $0.type == .swipeLeft })
        let previousSwipeLefts = previousSwipeLeftActions.map { $0.objectId }
        
        FirebaseFunctionsManager.shared.getFlow(swipeLeftIds: previousSwipeLefts, algorithmIndex: algorithmIndex) { postModels in
            completion(postModels)
        }
    }
}
