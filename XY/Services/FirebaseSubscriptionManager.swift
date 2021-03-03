//
//  PostSubscriptionManager.swift
//  XY
//
//  Created by Maxime Franchot on 21/01/2021.
//

import Foundation
import FirebaseFirestore

final class FirebaseSubscriptionManager {
    static let shared = FirebaseSubscriptionManager()
    private init() { }
    
    var listeners = [String: ListenerRegistration]()
    
    public func registerXPUpdates(for documentId: String, ofType type: XPLevelType, onUpdate: @escaping(XPModel) -> Void) {
        let collection: String = {
            switch type {
            case .post: return FirebaseKeys.CollectionPath.posts
            case .user: return FirebaseKeys.CollectionPath.users
            case .viral: return FirebaseKeys.CollectionPath.virals
            case .challenge: return FirebaseKeys.CollectionPath.challenges
            }
        }()
        
        let listener = FirestoreReferenceManager.root.collection(collection)
            .document(documentId).addSnapshotListener { (snapshot, error) in
                guard let data = snapshot?.data(), error == nil else {
                    print(error ?? "An error occurred while fetching data for document: \(documentId)")
                    return
                }
                
                let xp = data["xp"] as! Int
                let level = data["level"] as! Int
                let xpLevelModel = XPModel(type: type, xp: xp, level: level)
                
                onUpdate(xpLevelModel)
        }
        
        listeners[documentId] = listener
    }
    
    public func deactivateXPUpdates(for documentId: String) {
        guard let listener = listeners[documentId] else {
            print("Listener for postId \(documentId) was not registered.")
            return
        }
        
        listener.remove()
        listeners.removeValue(forKey: documentId)
    }
}
