//
//  ChatFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import Foundation
import Firebase

final class ChatFirestoreManager {
    static let shared = ChatFirestoreManager()
    private init() { }
    
    func getLastMessageForConversation(withId conversationID: String, completion: @escaping(Result<Message, Error>) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations)
            .document(conversationID)
            .collection(FirebaseKeys.CollectionPath.messages)
            .order(by: FirebaseKeys.ConversationKeys.MessagesKeys.timestamp, descending: false)
            .limit(toLast: 1)
            .getDocuments() { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let querySnapshot = querySnapshot {
                    for doc in querySnapshot.documents {
                        let data = doc.data()
                        let message = Message(
                            senderId: data[FirebaseKeys.ConversationKeys.MessagesKeys.sender] as! String,
                            messageText: data[FirebaseKeys.ConversationKeys.MessagesKeys.message] as! String,
                            timestamp: (data[FirebaseKeys.ConversationKeys.MessagesKeys.timestamp] as! Firebase.Timestamp).dateValue()
                        )
                        completion(.success(message))
                        return
                    }
                }
            }
    }
    
    func getMessagesForConversation(withId conversationID: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations)
            .document(conversationID)
            .collection(FirebaseKeys.CollectionPath.messages)
            .order(by: FirebaseKeys.ConversationKeys.MessagesKeys.timestamp, descending: false)
            .getDocuments() { messageDocuments, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let messageDocuments = messageDocuments {
                var messages : [Message] = []
                for messageDoc in messageDocuments.documents {
                    let data = messageDoc.data()
                    let message = Message(
                        senderId: data[FirebaseKeys.ConversationKeys.MessagesKeys.sender] as! String,
                        messageText: data[FirebaseKeys.ConversationKeys.MessagesKeys.message] as! String,
                        timestamp: (data[FirebaseKeys.ConversationKeys.MessagesKeys.timestamp] as! Firebase.Timestamp).dateValue()
                    )
                    messages.append(message)
                }
                completion(.success(messages))
            }
        }
    }
    
    func sendChat(conversationID: String, messageText: String, completion: @escaping(Result<String, Error>) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        let newMessageDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations).document(conversationID).collection(FirebaseKeys.CollectionPath.messages).document()
        
        let messageData: [String: Any] = [
            FirebaseKeys.ConversationKeys.MessagesKeys.sender: userId,
            FirebaseKeys.ConversationKeys.MessagesKeys.message: messageText,
            FirebaseKeys.ConversationKeys.MessagesKeys.timestamp: FieldValue.serverTimestamp()
        ]
        
        newMessageDocument.setData(messageData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(newMessageDocument.documentID))
            }
        }
    }
}
