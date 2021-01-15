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
                
                FirebaseDownload.getProfile(userId: otherMemberId) {_, profile, error in
                    if let error = error { print("Error fetching profile for conversation: \(error)") }
                    
                    if let profile = profile {
                        self.delegate.onFetchedProfileData(profile, indexRow: self.indexRow)
                        
                        // Fetch profile image
                        FirebaseDownload.getImage(imageId: profile.profileImageId) { image, error in
                            if let error = error { print("Error fetching profile image for user: \(error)") }
                            
                            if let image = image {
                                self.delegate.onFetchedProfileImage(image, indexRow: self.indexRow)
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
