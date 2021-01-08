//
//  FirebaseUpload.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation

import Firebase
import FirebaseStorage
import FirebaseAuth

class FirebaseUpload {
    
    static func createPost(caption: String, image: UIImage, completion: @escaping(Result<PostData, Error>) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
        userDocument.getDocument() { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let snapshot = snapshot, let profileId = snapshot.get(FirebaseKeys.UserKeys.profile) as? String {
                // Upload photo in post
                let storage = Storage.storage()
                
                let storageRef = storage.reference()
                let uuid = UUID().uuidString + ".png"
                let imageRef = storageRef.child(uuid)
                
                let uploadTask = imageRef.putData(image.pngData()!, metadata: nil) { (metadata, error) in
                    if let error = error {
                        completion(.failure(error))
                    }
                    
                    // Upload post to firestore
                    var postData = PostData(id: "", userId: uid, timestamp: Date(), content: caption)
                    postData.images = [uuid]
                    
                    let postDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).addDocument(data: postData.toUpload()) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    }
                    
                    postData.id = postDocument.documentID
                    completion(.success(postData))
                }
                
                //TODO: Add post to profile posts
            }
        }
    }
    
    static func editProfileInfo(profileData: UpperProfile, completion: @escaping(Result<Void, Error>) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(uid)
        userDocument.getDocument() { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let snapshot = snapshot, let profileId = snapshot.get(FirebaseKeys.UserKeys.profile) as? String {
                let profile = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.profile).document(profileId)
                
                do {
                    profile.setData(profileData.editProfileData, merge: true) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        
                        completion(.success(()))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func changeProfileImage(profileImage: UIImage) {
        
    }
}
