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
    
    static func getOwnerUser(forProfileId profileId: String, completion: @escaping(String?, Error?) -> Void) {
        let userDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users)
            .whereField(FirebaseKeys.UserKeys.profile, isEqualTo: profileId).limit(to: 1)
        
        userDoc.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            }
            if let querySnapshot = querySnapshot, let doc = querySnapshot.documents.first {
                
                let userData = doc.data()
                if let profileId = userData[FirebaseKeys.UserKeys.profile] as? String {
                    completion(doc.documentID, nil)
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    static func getUserIdForXyname(_ xyname: String, completion: @escaping(String?, Error?) -> Void) {
        let userDoc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users)
            .whereField(FirebaseKeys.UserKeys.xyname, isEqualTo: xyname).limit(to: 1)
        
        userDoc.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            }
            if let querySnapshot = querySnapshot, let doc = querySnapshot.documents.first {
                
                let userData = doc.data()
                if let profileId = userData[FirebaseKeys.UserKeys.profile] as? String {
                    completion(doc.documentID, nil)
                } else {
                    fatalError()
                }
            }
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
                    let newPost = PostModel(from: doc.data(), id: doc.documentID)

                    posts.append(newPost)
                }
                completion(posts, nil)
            }
        }
    }
    
    static func getMoments(completion: @escaping(Result<[MomentModel], Error>) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.moments)
            .order(by: FirebaseKeys.MomentsKeys.timestamp, descending: true)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let querySnapshot = querySnapshot {
                var moments = [MomentModel]()
                
                for doc in querySnapshot.documents {
                    
                    moments.append(
                        MomentModel(
                            from: doc.data(),
                            id: doc.documentID
                        )
                    )
                }
                completion(.success(moments))
            }
        }
    }
    
    static func getVirals(completion: @escaping(Result<[ViralModel], Error>) -> Void) {
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.virals)
            .order(by: FirebaseKeys.ViralKeys.level, descending: true)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let querySnapshot = querySnapshot {
                var virals = [ViralModel]()
                
                for doc in querySnapshot.documents {
                    
                    let viralModel = ViralModel(
                        from: doc.data(),
                        id: doc.documentID
                    )
                    if viralModel.lives <= 0 {
                        continue
                    }
                    
                    virals.append(viralModel)
                }
                
                // Reorder to random and return
                completion(.success(virals.shuffled()))
            }
        }
    }
    
    static func getProfile(profileId: String, completion: @escaping(ProfileModel?, Error?) -> Void) {

        let profileRef = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileId)
        profileRef.getDocument() { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            
            if let snapshot = snapshot, let profileData = snapshot.data() {
                let profile = ProfileModel(data: profileData, id: snapshot.documentID)
                
                completion(profile, nil)
            }
        }
    }
    
    static func getImage(imageId: String, completion: @escaping(UIImage?, Error?) -> Void) {
        let storage = Storage.storage()
        
        let imageRef = storage.reference(withPath: imageId)
        
        imageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
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
                completion(ConversationModel(data, id: document.documentID), nil)
            }
        }
    }
    
    static func getConversationWithUser(otherUserId: String, completion: @escaping(Result<ConversationModel?, Error>) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations)
            .whereField("\(FirebaseKeys.ConversationKeys.members).\(userId)", isEqualTo: true)
            .whereField("\(FirebaseKeys.ConversationKeys.members).\(otherUserId)", isEqualTo: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let querySnapshot = querySnapshot {
                    for doc in querySnapshot.documents {
                        let conversation = ConversationModel(doc.data(), id: doc.documentID)
                        completion(.success(conversation))
                        return
                    }
                    completion(.success(nil))
                }
            }
    }
}
