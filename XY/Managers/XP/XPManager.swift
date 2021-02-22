//
//  XPManager.swift
//  XY
//
//  Created by Maxime Franchot on 22/02/2021.
//

import Foundation
import Firebase

final class XPManager {
    static let shared = XPManager()
    private init() { }
    
    var subscriptions = [String: ListenerRegistration]()
    
    /// Subscribes to the "xp" and "level" for the given document path
    func subscribeToDocument(collectionName: String, docID: String, callback: @escaping(Int?, Int?) -> Void) {
        let listener = FirestoreReferenceManager.root.collection(collectionName).document(docID).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
                if let data = snapshot.data(), let level = data["level"] as? Int, let xp = data["xp"] as? Int {
                    callback(level, xp)
                }
            }
        }
        
        subscriptions[docID] = listener
    }
    
    func unsubscribeToID(docID: String) {
        if let subscription = subscriptions[docID] {
            subscription.remove()
        }
        subscriptions.removeValue(forKey: docID)
    }
}
