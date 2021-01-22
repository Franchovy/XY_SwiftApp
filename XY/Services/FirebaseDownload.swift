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
    
    static func getPost(for id: String, completion: @escaping(PostModel?, Error?) -> Void) {
        let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document(id)
        
        document.getDocument { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                completion(nil, error)
                return
            }
            
            if let postData = snapshot.data() as? [String: Any] {
                let postModel = PostModel(from: postData, id: document.documentID)
                completion(postModel, nil)
            } else {
                completion(nil, nil)
            }
        }
    }

    static func getFlow(completion: @escaping([PostModel]?, Error?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: true)
                    .getDocuments() { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            if let documents = snapshot?.documents {
                var posts: [PostModel] = []
                for doc in documents {
                    
                    var newPost = PostModel(from: doc.data(), id: doc.documentID)

                    posts.append(newPost)
                }
                completion(posts, nil)
            }
        }
    }
    
    static func getFlowUpdates(completion: @escaping([PostModel]?, Error?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: true)
            .addSnapshotListener() { snapshotDocuments, error in
            if let error = error { completion(nil, error) }
            
            guard let snapshotDocuments = snapshotDocuments else { return }
            
            var postDataArray: [PostModel] = []
            
            for documentChanges in snapshotDocuments.documentChanges {
                if documentChanges.type == .added {
                    // Append post
                    let postDocumentData = documentChanges.document.data()
                    let postData = PostModel(from: postDocumentData, id: documentChanges.document.documentID)
                    postDataArray.append(postData)
                }
            }
                
            
            completion(postDataArray, nil)
            
        }
    }
    
    static func getFlowForProfile(userId: String, completion: @escaping([PostModel]?, Error?) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .whereField(FirebaseKeys.PostKeys.author, isEqualTo: userId)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: true)
                    .getDocuments() { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            if let documents = snapshot?.documents {
                var posts: [PostModel] = []
                for doc in documents {
                    var newPost = PostModel(from: doc.data(), id: doc.documentID)

                    posts.append(newPost)
                }
                completion(posts, nil)
            }
        }
    }
    
    static func getProfileId(userId: String, completion: @escaping(String?, Error?) -> Void) {
        let userRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId)
        
        userRef.getDocument() { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil, error)
                return
            }
            
            if let userData = snapshot.data() as? [String: Any] {
                let profileId = userData[FirebaseKeys.UserKeys.profile] as! String
                completion(profileId, nil)
            }
        }
    }
    
    static func getProfile(profileId: String, completion: @escaping(ProfileModel?, Error?) -> Void) {

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