//
//  ConversationFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import Foundation
import Firebase

final class ConversationFirestoreManager {
    static let shared = ConversationFirestoreManager()
    private init() { }
    
    func getConversations(completion: @escaping(Result<[ConversationModel], Error>) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations)
            .whereField("\(FirebaseKeys.ConversationKeys.members).\(userId)", isEqualTo: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let querySnapshot = querySnapshot {
                    var conversationModels = [ConversationModel]()
                    
                    for doc in querySnapshot.documents {
                        let model = ConversationModel(doc.data(), id: doc.documentID)
                        conversationModels.append(model)
                    }
                    
                    conversationModels.sort { (convModel1, convModel2) -> Bool in
                        convModel1.timestamp < convModel2.timestamp
                    }
                    
                    completion(.success(conversationModels))
                }
            }
    }
    
    func startConversation(withUser otherUserId: String, message: String, completion: @escaping(Result<ConversationModel, Error>) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        let newConversationDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations).document()
        
        let newConversationData : [String: Any] = [
            FirebaseKeys.ConversationKeys.members : [ userId: true, otherUserId: true ],
            FirebaseKeys.ConversationKeys.timestamp : FieldValue.serverTimestamp(),
            FirebaseKeys.ConversationKeys.level : 0,
            FirebaseKeys.ConversationKeys.xp : 0,
            FirebaseKeys.ConversationKeys.mostRecentMessageTimestamp : FieldValue.serverTimestamp()
        ]
        
        newConversationDocument.setData(newConversationData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Send first message
                
                let firstMessageDocument = newConversationDocument.collection(FirebaseKeys.ConversationKeys.messages).document()
                
                let messageData:[String: Any] = [
                    FirebaseKeys.ConversationKeys.MessagesKeys.message : message,
                    FirebaseKeys.ConversationKeys.MessagesKeys.sender : userId,
                    FirebaseKeys.ConversationKeys.MessagesKeys.timestamp : FieldValue.serverTimestamp()
                ]
                
                firstMessageDocument.setData(messageData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(ConversationModel(newConversationData, id: newConversationDocument.documentID)))
                    }
                }
            }
        }
    }
}
