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
    
    
}
