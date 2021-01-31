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

var TESTMODE = true

class FirebaseUpload {
    
    static func createPost(caption: String, image: UIImage, completion: @escaping(Result<PostModel, Error>) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        
        if TESTMODE {
            print("UPLODING POST IN TESTMODE")
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                var postData = PostModel(id: "", userId: uid, timestamp: Date(), content: caption, images: [], level: 0, xp: 0)
                completion(.success(postData))
            }
        } else {
            uploadImage(image: image) { imageRef, error in
                if let error = error {
                    completion(.failure(error))
                }
                if let imageRef = imageRef {
                    // Upload post to firestore
                    var postData = PostModel(id: "", userId: uid, timestamp: Date(), content: caption, images: [imageRef], level: 0, xp: 0)
                    
                    let postDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document()
                    
                    postData.id = postDocument.documentID
                    postDocument.setData(postData.toUpload(), merge: false) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        completion(.success(postData))
                    }
                }
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
    
    static func editProfileInfo(profileData: ProfileModel, completion: @escaping(Result<Void, Error>) -> Void) {
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
    
    static func sendSwipeRight(postId: String, completion: @escaping(Result<Void, Error>) -> Void) {
        sendSwipeTransaction(postId: postId, transactionXP: 10, completion: completion)
    }
    
    static func sendSwipeLeft(postId: String, completion:  @escaping(Result<Void, Error>) -> Void) {
        sendSwipeTransaction(postId: postId, transactionXP: -50, completion: completion)
    }
    
    static func sendSwipeTransaction(postId: String, transactionXP: Int, completion: @escaping(Result<Void, Error>) -> Void) {
        
        let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(Auth.auth().currentUser!.uid)
        
        let postDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document(postId)
        let updatePostData = [ FirebaseKeys.PostKeys.swipeRight : FieldValue.increment(Int64(1)), FirebaseKeys.PostKeys.xp : FieldValue.increment(Int64(transactionXP)) ]
        
        incrementDecrementXP(documentRef: userDocument, xpLevelType: .user, transactionXP: -transactionXP) { error in
            if let error = error { completion(.failure(error)) }
            
            incrementDecrementXP(documentRef: postDocument, xpLevelType: .post, transactionXP: transactionXP) { error in
                if let error = error { completion(.failure(error)) }
                
                // Add swipe right action
                let swipeRightActionData = Action.getSwipeRightAction(postId: postId, xp: transactionXP)
                FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.actions).addDocument(data: swipeRightActionData) { error in
                    if let error = error { completion(.failure(error)) }
                    
                    completion(.success(()))
                }
            }
        }
    }
    
    static func incrementDecrementXP(documentRef: DocumentReference, xpLevelType: XPLevelType, transactionXP: Int, completion: @escaping(Error?) -> Void) {
        // Update xp
        
        let updateData = [ FirebaseKeys.UserKeys.xp : FieldValue.increment(Int64(transactionXP)) ]
        
        documentRef.updateData(updateData) { error in
            if let error = error { completion(error) }
            
            documentRef.getDocument() { snapshot, error in
                if let error = error { completion(error) }
                
                if let snapshot = snapshot {
                    // Check for level up
                    
                    guard let data = snapshot.data(), let level = data["level"] as? Int, let xp = data["xp"] as? Int else { fatalError("Document does not have level and/or xp keys! Please check the document reference is correct") }
                    
                    let nextLevelXP = XPModel.LEVELS[xpLevelType]![level]
                    if xp >= nextLevelXP {
                        // Level up
                        
                        // Level up post
                        let levelUpData = [ "level" : level + 1 , "xp" : xp - nextLevelXP ]
                        documentRef.updateData(levelUpData) { error in
                            if let error = error { completion(error) }
                            
                            // Add Level Up Action
                            let levelUpActionData = Action.getLevelUpAction(docId: documentRef.documentID, level: level + 1)
                            FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.actions).addDocument(data: levelUpActionData) { error in
                                if let error = error { completion(error) }
                            
                                // Give XP to users since last level up
                                if xpLevelType == .post {
                                    getXPContributors(postId: documentRef.documentID) { contributorsList, error in
                                        if let error = error { completion(error) }
                                        
                                        completion(nil)
                                    }
                                } else {
                                    completion(nil)
                                }
                            }
                        }
                        
                    } else if xp < 0 {
                        // Level down
                        
                        if level == 0 {
                            // Delete post
                            let doc = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document(documentRef.documentID)
                            doc.delete() { error in
                                if let error = error { completion(error) }
                                else { completion(nil) }
                            }
                        }
                        
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    static func deleteAllNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(uid).collection(FirebaseKeys.NotificationKeys.notificationsCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching notification documents: \(error)")
            }
            if let documents = querySnapshot?.documents {
                for document in documents {
                    FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(uid).collection(FirebaseKeys.NotificationKeys.notificationsCollection).document(document.documentID).delete { (error) in
                        if let error = error {
                            print("Error deleting document with id \(document.documentID): \(error)")
                        }
                    }
                }
            }
        }
    }
    
    /// Returns map of userIds -> xp given
    static func getXPContributors(postId: String, completion: @escaping([String: Int]?, Error?) -> Void) {
        // Get timestamp of previous level up from action script
        // Get users that gave xp to the post since the last level up
        completion(nil,nil)
    }
    
    static func sendMessage(conversationId: String, message: String, completion: @escaping(Result<Void, Error>) -> Void) {
        let messagesCollection = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations).document(conversationId).collection(FirebaseKeys.CollectionPath.messages)
        
        let messageData = MessageModel(senderId: Auth.auth().currentUser!.uid, message: message).toNewMessageData()
        messagesCollection.addDocument(data: messageData) { error in
            if let error = error { completion(.failure(error)) }
            else {
                completion(.success(()))
            }
        }
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
    
    static func uploadVideo(with url: URL, completion: @escaping(Result<String,Error>) -> Void) {
        // Upload photo in post
        let storage = Storage.storage()
        
        var uuid: String!
        var metadata = StorageMetadata()
        
        uuid = UUID().uuidString + ".mov"
        metadata.contentType = "video/quicktime"
        
        let storageRef = storage.reference()
        let videoRef = storageRef.child(uuid)
        
        videoRef.putFile(from: url, metadata: metadata)  { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            }

            if let metadata = metadata {
                completion(.success(videoRef.fullPath))
            }
        }
    }
    
    static func deleteNotification(notificationId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let notificationDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.notifications).document(userId).collection(FirebaseKeys.NotificationKeys.notificationsCollection).document(notificationId)
        
        notificationDocument.delete()
    }
    
    static func createViral(caption: String, videoPath: String, completion: @escaping(Result<ViralModel, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        FirebaseDownload.getProfileId(userId: userId) { (profileId, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let profileId = profileId {
                let viralData: [String: Any] = [
                    FirebaseKeys.ViralKeys.videoRef: videoPath,
                    FirebaseKeys.ViralKeys.profileId: profileId,
                    FirebaseKeys.ViralKeys.caption: caption,
                    FirebaseKeys.ViralKeys.livesLeft: XPModel.LIVES[.viral]![0],
                    FirebaseKeys.ViralKeys.xp: 0,
                    FirebaseKeys.ViralKeys.level: 0
                ]
                
                let viralDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.virals).document()
                viralDocument.setData(viralData) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    }
                    let viralModel = ViralModel.init(from: viralData, id: viralDocument.documentID)
                    completion(.success(viralModel))
                }
            }
        }
    }

//    static func swipeRightViral
    
    
    static func createMoment(caption: String, videoPath: String, completion: @escaping(Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
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
    
    enum ChangePasswordError: Error {
        case invalidOldPassword
        case otherError
    }
    static func changePassword(oldPassword: String, newPassword: String, completion: @escaping(Result<Void,Error>) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: oldPassword) { (result, error) in
            if let error = error {
                print("Error resetting password: \(error)")
                completion(.failure(error))
            }
            if result != nil {
                Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                    if let error = error {
                        completion(.failure(error))
                    }
                    completion(.success(()))
                })
            }
        }
    }
}
