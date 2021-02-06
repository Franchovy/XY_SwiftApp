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
    
    var flow = [PostModel]()
    
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
    
    func getFlow(completion: @escaping(Result<[PostModel], Error>) -> Void) {
        let previousSwipeLefts = ActionManager.shared.previousActions.filter({ $0.type == .swipeLeft }).map { $0.objectId }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: false)
                    .getDocuments() { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            if let documents = snapshot?.documents {
                
                for doc in documents {
                    var newPost = PostModel(from: doc.data(), id: doc.documentID)
                    
                    // Apply Filters to the flow
                    if previousSwipeLefts.contains(where: { $0 == newPost.id }) {
                        continue
                    }
                    //
                    self.flow.append(newPost)
                }
                completion(.success(self.flow))
            }
        }
    }
    
    func getFlowUpdates(completion: @escaping(Result<[PostModel], Error>) -> Void) {
        let previousSwipeLefts = ActionManager.shared.previousActions.filter({ $0.type == .swipeLeft }).map { $0.objectId }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts)
            .order(by: FirebaseKeys.PostKeys.timestamp, descending: false)
            .addSnapshotListener() { snapshotDocuments, error in
                if let error = error { completion(.failure(error)) }
            
            guard let snapshotDocuments = snapshotDocuments else { return }
            
            var postDataArray: [PostModel] = []
            
            for documentChanges in snapshotDocuments.documentChanges {
                if documentChanges.type == .added {
                    if self.flow.contains(where: { $0.id == documentChanges.document.documentID }) {
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
    }
}
