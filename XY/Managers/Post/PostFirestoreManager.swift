//
//  PostFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 16/03/2021.
//

import UIKit
import Firebase

final class PostFirestoreManager {
    static var shared = PostFirestoreManager()
    private init() { }
    
    func uploadPost(with caption: String, image: UIImage, completion: @escaping(Result<NewPostViewModel, Error>) -> Void) {
        guard let userID = AuthManager.shared.userId, let profileData = ProfileManager.shared.ownProfile else {
            return
        }
        
        let postDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document()
        
        // Create firebase storage: /postId/
        StorageManager.shared.uploadPhoto(image, storageId: postDocument.documentID) { (result) in
            switch result {
            case .success(let imageId):
                let postViewModel = NewPostViewModel(
                    id: postDocument.documentID,
                    nickname: profileData.nickname,
                    timestamp: Date(),
                    content: caption,
                    userId: userID,
                    profileId: profileData.profileId,
                    level: 0,
                    xp: 0
                )
                
                let postData:[String: Any] = [
                    FirebaseKeys.PostKeys.author : userID,
                    FirebaseKeys.PostKeys.timestamp : FieldValue.serverTimestamp(),
                    FirebaseKeys.PostKeys.level : 0,
                    FirebaseKeys.PostKeys.xp : 0,
                    FirebaseKeys.PostKeys.postData : [
                        FirebaseKeys.PostKeys.PostData.caption : caption,
                        FirebaseKeys.PostKeys.PostData.imageRef : imageId
                    ]
                ]
                
                postDocument.setData(postData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(postViewModel))
                    }
                }
                
            case .failure(let error):
                print("Error uploading image: \(error)")
            }
        }
    }
    
}
