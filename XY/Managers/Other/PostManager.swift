//
//  PostManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/02/2021.
//

import Foundation
import UIKit
import Firebase

final class PostManager {
    static let shared = PostManager()
    private init() { }
    
    var currentFlow = [PostModel]()
    var allPosts = [PostModel]()
    var userPostIndex = 0
    
    var listeners = [ListenerRegistration]()
    
    public func createPost(caption: String, image: UIImage, completion: @escaping(Result<PostModel, Error>) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let postDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document()
        
        // Create firebase storage: /postId/
        StorageManager.shared.uploadPhoto(image, storageId: postDocument.documentID) { (result) in
            switch result {
            case .success(let imageId):
                var postModel = PostModel(
                    id: postDocument.documentID,
                    userId: uid,
                    timestamp: Date(),
                    content: caption,
                    images: [imageId],
                    level: 0,
                    xp: 0
                )
                
                postDocument.setData(postModel.toUpload()) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(postModel))
                    }
                }
                
            case .failure(let error):
                print("Error uploading image: \(error)")
            }
        }
    }
    
    func refreshIncrementIndex() {
        userPostIndex += 1
        
        UserDefaults.standard.setValue(userPostIndex, forKey: "flowRefreshIndex")
    }
    
    func getFlow(completion: @escaping(Result<[PostModel], Error>) -> Void) {
        let previousSwipeLeftActions = ActionManager.shared.previousActions.filter({ $0.type == .swipeLeft })
        let previousSwipeLefts = previousSwipeLeftActions.map { $0.objectId }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: true)
                    .getDocuments() { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            if let documents = snapshot?.documents {
                self.currentFlow = []
                
                var postsByUsers = [String : [PostModel]]()
                for doc in documents {
                    let newPost = PostModel(from: doc.data(), id: doc.documentID)
                    
                    if !self.allPosts.contains(where: { $0.id == newPost.id }) {
                        self.allPosts.append(newPost)
                    }
                    
                    // Apply Filters to the flow
                    if previousSwipeLefts.contains(where: { $0 == newPost.id }) {
                        continue
                    }
                    
                    if postsByUsers.keys.contains(where: { $0 == newPost.userId }) {
                        postsByUsers[newPost.userId]?.append(newPost)
                    } else {
                        postsByUsers[newPost.userId] = [newPost]
                    }
                }
                
                for keyValue in postsByUsers {
                    guard let postsByUser = postsByUsers[keyValue.key] else {
                        continue
                    }
                    let numPostsByUser = postsByUser.count
                    let postToAppend = postsByUser[self.userPostIndex % numPostsByUser]
                    
                    // Filter users on random chance if swiped left before
                    if ActionManager.shared.swipeLeftUserIds.contains(postToAppend.userId) {
                        // % chance to skip this user based on number of swipe lefts on their stuff before
                        let numSwipeLefts = ActionManager.shared.swipeLeftUserIds.filter({ $0 == postToAppend.userId }).count
                        guard Int.random(in: 0...numSwipeLefts) == 0  else {
                            continue
                        }
                    }
                    
                    self.currentFlow.append(postToAppend)
                }
                
                completion(.success(self.currentFlow))
            }
        }
    }
    
    func getFlowUpdates(completion: @escaping(Result<[PostModel], Error>) -> Void) {
        let previousSwipeLefts = ActionManager.shared.previousActions.filter({ $0.type == .swipeLeft }).map { $0.objectId }
        
        let listener = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: false)
            .addSnapshotListener() { snapshotDocuments, error in
                if let error = error { completion(.failure(error)) }
            
            guard let snapshotDocuments = snapshotDocuments else { return }
            
            var postDataArray: [PostModel] = []
            
            for documentChanges in snapshotDocuments.documentChanges {
                if documentChanges.type == .added {
                    if self.allPosts.contains(where: { $0.id == documentChanges.document.documentID }) {
                        continue
                    }
                    
                    let postDocumentData = documentChanges.document.data()
                    let newPost = PostModel(from: postDocumentData, id: documentChanges.document.documentID)
                    
                    // Filter
                    if previousSwipeLefts.contains(where: { $0 == newPost.id }) {
                        continue
                    }
                    
                    // Append
                    postDataArray.append(newPost)
                }
            }
            
            completion(.success(postDataArray))
        }
        
        self.listeners.append(listener)
    }
    
    func deactivateFlowListeners() {
        for listener in listeners {
            listener.remove()
        }
        listeners = []
    }
}
