//
//  ConversationFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import Foundation

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
}
