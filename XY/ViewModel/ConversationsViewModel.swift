//
//  ConversationsViewModel.swift
//  XY_APP
//
//  Created by Maxime Franchot on 12/01/2021.
//

import UIKit
import Firebase

protocol ConversationViewModelDelegate {
    func onFetchedPreviewMessage(_ message: String, indexRow: Int)
    func onFetchedProfileData(_ profile: ProfileModel, indexRow: Int)
    func onFetchedProfileImage(_ image: UIImage, indexRow: Int)
}

class ConversationViewModel {
    var id: String
    var conversation: ConversationPreview
    var messages: [MessageModel] = []
    
    var delegate: ConversationViewModelDelegate!
    var indexRow: Int
    
    init(conversationId : String, indexRow: Int) {
        // Fetch conversation data
        self.indexRow = indexRow
        self.id = conversationId
        self.conversation = ConversationPreview(conversationId: conversationId)
    }
    
    func fetch(_ completion: @escaping() -> Void) {
        FirebaseDownload.getConversation(conversationId: id) { conversation, error in
            if let error = error { print("Error fetching conversation: \(error)") }
            
            if let conversation = conversation {
                // Fetch preview message
                FirebaseDownload.getMessages(conversationId: self.id) { messages, error in
                    if let error = error { print("Error fetching conversation: \(error)") }
                    
                    if let messages = messages {
                        self.messages = messages
                        self.delegate.onFetchedPreviewMessage(messages[0].message, indexRow: self.indexRow)
                    }
                }
                
                // Fetch other profile
                
                // Isolate other member user id
                let otherMemberId = conversation.members.drop(while: { $0.isEqual(Auth.auth().currentUser!.uid) } ).first!
                
                FirebaseDownload.getProfileId(userId: otherMemberId) {profileId, error in
                    if let error = error { print("Error fetching profile for conversation: \(error)") }
                    
                    if let profileId = profileId {
                        
                        FirebaseDownload.getProfile(profileId: profileId) { (profileData, error) in
                            guard let profileData = profileData, error == nil else {
                                print(error ?? "Error fetching profile data for id: \(profileId)")
                                return
                            }
                            
                            self.delegate.onFetchedProfileData(profileData, indexRow: self.indexRow)
                        
                            // Fetch profile image
                            FirebaseDownload.getImage(imageId: profileData.profileImageId) { image, error in
                                if let error = error { print("Error fetching profile image for user: \(error)") }
                                
                                if let image = image {
                                    self.delegate.onFetchedProfileImage(image, indexRow: self.indexRow)
                                }
                            }
                        }
                    }
                }
                
                // Call completion
                completion()
            }
        }
    }
    
}
