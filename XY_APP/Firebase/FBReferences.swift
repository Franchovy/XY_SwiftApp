//
//  FBReferences.swift
//  XY_APP
//
//  Created by Maxime Franchot on 04/01/2021.
//

import Firebase

struct FirestoreReferenceManager {
    static let environment = "dev"
    
    static let db = Firestore.firestore()
    static let root = db.collection(environment).document(environment)

    static func getMessagesForConversation(conversationId: String) -> DocumentReference {
        /// Returns the messages document reference inside this conversation
        return FirestoreReferenceManager.root.collection(conversations).document(conversationId).collection(messages).document(messages)
    }
}
