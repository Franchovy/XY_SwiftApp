//
//  FirebaseUpload.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/01/2021.
//

import Foundation
import FirebaseStorage
import Firebase

class FirebaseUpload {
    
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
    
    static func editProfileInfo(profileData: ProfileModel, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let userId = AuthManager.shared.userId else { return }
        
        let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId)
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
    
    
    static func deleteAllNotifications() {
        guard let userId = AuthManager.shared.userId else { return }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(userId).collection(FirebaseKeys.NotificationKeys.notificationsCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching notification documents: \(error)")
            }
            if let documents = querySnapshot?.documents {
                for document in documents {
                    FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(userId).collection(FirebaseKeys.NotificationKeys.notificationsCollection).document(document.documentID).delete { (error) in
                        if let error = error {
                            print("Error deleting document with id \(document.documentID): \(error)")
                        }
                    }
                }
            }
        }
    }
    
    static func sendReport(message: String, postId: String) {
        FirestoreReferenceManager.root.collection("reports").addDocument(data:
                [
                    "postId" : postId,
                    "message" : message,
                    "timestamp" : FieldValue.serverTimestamp()
                ]
            )
        
    }
    
    /// Returns map of userIds -> xp given
    static func getXPContributors(postId: String, completion: @escaping([String: Int]?, Error?) -> Void) {
        // Get timestamp of previous level up from action script
        // Get users that gave xp to the post since the last level up
        completion(nil,nil)
    }
    
    /// Returns conversation id
    static func createConversation(otherMemberId: String, newMessage: String, completion: @escaping(Result<String, Error>) -> Void) {
        
        let newConversation = ConversationModel.newConversationData(members: [ Auth.auth().currentUser!.uid, otherMemberId ])
        let newConversationDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations).addDocument(data: newConversation) { error in if let error = error { completion(.failure(error)) } }
        
        let newMessageData : [ String : Any ] = [
            FirebaseKeys.ConversationKeys.MessagesKeys.message : newMessage,
            FirebaseKeys.ConversationKeys.MessagesKeys.sender : Auth.auth().currentUser!.uid,
            FirebaseKeys.ConversationKeys.MessagesKeys.timestamp : FieldValue.serverTimestamp()
        ]
        
        let messageDocument = newConversationDocument.collection(FirebaseKeys.CollectionPath.messages).addDocument(data: newMessageData) { error in
            if let error = error { completion(.failure(error)) }
            completion(.success(newConversationDocument.documentID))
        }
    }
    
    static func deleteNotification(notificationId: String) {
        guard let userId = AuthManager.shared.userId else { return }
        
        let notificationDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(userId).collection(FirebaseKeys.NotificationKeys.notificationsCollection).document(notificationId)
        
        notificationDocument.delete()
    }
    
    
    // MARK: - Moments
    
    static func createMoment(caption: String, videoPath: String, completion: @escaping(Result<String, Error>) -> Void) {
        guard let userId = AuthManager.shared.userId else { return }
        
        let momentData: [String: Any] = [
            FirebaseKeys.MomentsKeys.videoRef: videoPath,
            FirebaseKeys.MomentsKeys.author: userId,
            FirebaseKeys.MomentsKeys.timestamp: FieldValue.serverTimestamp()
        ]
        
        let momentDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.moments).document()
            
        momentDocument.setData(momentData) { (error) in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(momentDocument.documentID))
        }
    }
}
