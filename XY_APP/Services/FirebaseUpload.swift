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
                uploadImage(image: image) { imageRef, error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    if let imageRef = imageRef {
                        // Upload post to firestore
                        var postData = PostData(id: "", userId: uid, timestamp: Date(), content: caption, level: 0, xp: 0)
                        postData.images = [imageRef]
                        
                        let postDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).addDocument(data: postData.toUpload()) { error in
                            if let error = error {
                                completion(.failure(error))
                            }
                        }
                        
                        postData.id = postDocument.documentID
                        completion(.success(postData))
                    }
                }
                
                //TODO: Add post to profile posts
            }
        }
    }
    
    static func uploadImage(image: UIImage, completion: @escaping(String?, Error?) -> Void) {
        // Upload photo in post
        let storage = Storage.storage()
        
        var uuid: String!
        var metadata = StorageMetadata()
        
        var imageData = image.pngData()!
        if imageData.count > 1 * 1024 * 1024 {
            while imageData.count > 1 * 1024 * 1024 {
                imageData = image.jpegData(compressionQuality: 0.0)!
            }
            uuid = UUID().uuidString + ".jpg"
            metadata.contentType = "image/jpeg"
        } else {
            metadata.contentType = "image/png"
            uuid = UUID().uuidString + ".png"
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child(uuid)
        
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(nil, error)
            }
            
            if let metadata = metadata {
                completion(imageRef.fullPath, nil)
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
    
    static func sendSwipeRight(postId: String, completion: @escaping(Result<Void, Error>) -> Void) {
        
        let transactionXP = 10
        
        let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(Auth.auth().currentUser!.uid)
        let updateUserData = [ FirebaseKeys.UserKeys.xp : FieldValue.increment(Int64(-transactionXP)) ]
        
        let postDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document(postId)
        let updatePostData = [ FirebaseKeys.PostKeys.swipeRight : FieldValue.increment(Int64(1)), FirebaseKeys.PostKeys.xp : FieldValue.increment(Int64(transactionXP)) ]
        
        userDocument.updateData(updateUserData) { error in
            if let error = error { completion(.failure(error)) }
            
            postDocument.updateData(updatePostData) { error in
                if let error = error { completion(.failure(error)) }
                
                let swipeRightActionData = Action.getSwipeRightAction(postId: postId, xp: transactionXP)
                FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.actions).addDocument(data: swipeRightActionData) { error in
                    if let error = error { completion(.failure(error)) }
                    
                    // State check for level up
                    postDocument.getDocument() { snapshot, error in
                        if let error = error { completion(.failure(error)) }
                        
                        guard let data = snapshot?.data() else { fatalError() }
                        
                        let xp = data[FirebaseKeys.PostKeys.xp] as! Int
                        let level = data[FirebaseKeys.PostKeys.level] as! Int
                        
                        let nextLevelXP = XPModel.LEVELS[.post]![level]
                        if xp > nextLevelXP {
                            
                            let levelUpPostData = [ FirebaseKeys.PostKeys.level : level + 1 , FirebaseKeys.PostKeys.xp : 0 ]
                            postDocument.updateData(levelUpPostData) { error in
                                if let error = error { completion(.failure(error)) }
                                
                                let levelUpActionData = Action.getLevelUpAction(postId: postId, level: level + 1)
                                FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.actions).addDocument(data: levelUpActionData) { error in
                                    if let error = error { completion (.failure(error)) }
                                    
                                    completion(.success(()))
                                }
                            }
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    static func levelUpPost(postId: String, completion: @escaping(Result<Void, Error>) -> Void) {
        
    }
}
