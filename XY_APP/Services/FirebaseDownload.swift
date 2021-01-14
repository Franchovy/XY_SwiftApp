//
//  FirebaseDownload.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseDownload {
    
    static func getFlow(completion: @escaping([PostData]?, Error?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: true)
                    .getDocuments() { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            if let documents = snapshot?.documents {
                var posts: [PostData] = []
                for doc in documents {
                    var newPost = PostData(doc.data(), id: doc.documentID)

                    posts.append(newPost)
                }
                completion(posts, nil)
            }
        }
    }
    
    static func getFlowForProfile(userId: String, completion: @escaping([PostData]?, Error?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .whereField(FirebaseKeys.PostKeys.author, isEqualTo: userId)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: true)
                    .getDocuments() { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            if let documents = snapshot?.documents {
                var posts: [PostData] = []
                for doc in documents {
                    var newPost = PostData(doc.data(), id: doc.documentID)

                    posts.append(newPost)
                }
                completion(posts, nil)
            }
        }
    }
    
    static func getProfile(userId: String, completion: @escaping(ProfileModel?, Error?) -> Void) {
        let userRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId)
        
        userRef.getDocument() { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            
            if let userData = snapshot?.data() as? [String: Any], let profileId = userData["profile"] as? String {
                let profileRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileId)
                profileRef.getDocument() { snapshot, error in
                    if let error = error {
                        completion(nil, error)
                    }
                    
                    if let profileData = snapshot?.data() as? [String: Any] {
                        
                        let profile = ProfileModel(data: profileData)
                        
                        completion(profile, nil)
                    }
                }
            }
        }
    }
    
    static func getImage(imageId: String, completion: @escaping(UIImage?, Error?) -> Void) {
        let storage = Storage.storage()
        
        let imageRef = storage.reference(withPath: imageId)
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                completion(nil, error)
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image, nil)
            }
        }
    }
    
    // static func get flow [range of int] posts to get within algorithm
    
    static func getConversation(conversationId: String, completion: @escaping(ConversationModel?, Error?) -> Void ) {
        let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations).document(conversationId)
        
        document.getDocument() { snapshot, error in
            if let error = error { completion(nil, error) }
            
            if let snapshot = snapshot, let data = snapshot.data() {
                completion(ConversationModel(data), nil)
            }
        }
    }
    
    static func getMessages(conversationId: String, completion: @escaping([MessageModel]?, Error?) -> Void) {
        let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations).document(conversationId)
        
        document.collection(FirebaseKeys.CollectionPath.messages).getDocuments() { messageDocuments, error in
            if let error = error { completion(nil, error) }
            
            if let messageDocuments = messageDocuments {
                var messages : [MessageModel] = []
                for messageDoc in messageDocuments.documents {
                    let message = MessageModel(messageDoc.data())
                    messages.append(message)
                }
                completion(messages, nil)
            }
        }
    }
}
