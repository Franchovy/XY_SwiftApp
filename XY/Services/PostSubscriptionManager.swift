//
//  PostSubscriptionManager.swift
//  XY
//
//  Created by Maxime Franchot on 21/01/2021.
//

import Foundation
import FirebaseFirestore

final class PostSubscriptionManager {
    static let shared = PostSubscriptionManager()
    private init() { }
    
    var listeners = [String: ListenerRegistration]()
    
    public func registerXPUpdates(for postId: String, onUpdate: @escaping(XPModel) -> Void) {
        let listener = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .document(postId).addSnapshotListener { (snapshot, error) in
                guard let postData = snapshot?.data(), error == nil else {
                    print(error ?? "An error occurred while fetching postData for post: \(postId)")
                    return
                }
                
                let xp = postData[FirebaseKeys.PostKeys.xp] as! Int
                let level = postData[FirebaseKeys.PostKeys.level] as! Int
                let xpLevelModel = XPModel(type: .post, xp: xp, level: level)
                
                onUpdate(xpLevelModel)
        }
        
        listeners[postId] = listener
    }
    
    public func deactivateXPUpdates(for postId: String) {
        guard let listener = listeners[postId] else {
            print("Listener for postId \(postId) was not registered.")
            return
        }
        
        listener.remove()
        listeners.removeValue(forKey: postId)
    }
}
