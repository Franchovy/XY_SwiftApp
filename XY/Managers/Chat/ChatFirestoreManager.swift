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
    
    
    func getMessagesForConversation(withId conversationID: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations)
            .document(conversationID)
            .collection(FirebaseKeys.CollectionPath.messages)
            .getDocuments() { messageDocuments, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let messageDocuments = messageDocuments {
                var messages : [Message] = []
                for messageDoc in messageDocuments.documents {
                    let message = Message(
                        senderId: messageDoc[FirebaseKeys.ConversationKeys.MessagesKeys.sender] as! String,
                        messageText: messageDoc[FirebaseKeys.ConversationKeys.MessagesKeys.message] as! String,
                        timestamp: (messageDoc[FirebaseKeys.ConversationKeys.MessagesKeys.timestamp] as! Firebase.Timestamp).dateValue()
                    )
                    messages.append(message)
                }
                completion(.success(messages))
            }
        }
    }
    
    func sendChat(conversationID: String, chatMessage: Message, completion: @escaping(Result<String, Error>) -> Void){
        let newMessageDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations).document(conversationID).collection(FirebaseKeys.CollectionPath.messages).document()
        
        // ADD CHECK FOR CONVERSATION -> CREATE CONVERSATION
        
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        let messageData: [String: Any] = [
            FirebaseKeys.ConversationKeys.MessagesKeys.sender: chatMessage.senderId,
            FirebaseKeys.ConversationKeys.MessagesKeys.message: chatMessage.messageText,
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
