//
//  ConversationViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 15/02/2021.
//

import UIKit

final class ConversationViewModelBuilder {
    
    static func build(from model: ConversationModel, completion: @escaping(ConversationViewModel?) -> Void) {
        
        guard let otherUserId = model.members.filter( { $0 != AuthManager.shared.userId }).first else {
            return
        }
        
        var profileImage: UIImage?
        var nickname: String?
        var lastMessageText: String?
        var lastMessageTimestamp: Date?
        var unread: Bool?
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        
        // Fetch profile
          // Fetch profileImage
        ProfileManager.shared.fetchProfile(userId: otherUserId) { (result) in
            switch result {
            case .success(let profileModel):
                nickname = profileModel.nickname
                FirebaseDownload.getImage(imageId: profileModel.profileImageId) { image, error in
                    defer {
                        group.leave()
                    }
                    
                    if let error = error {
                        print(error)
                    } else if let image = image {
                        profileImage = image
                    }
                }
                
            case .failure(let error):
                print(error)
                group.leave()
            }
        }
        
        // Fetch first message
        ChatFirestoreManager.shared.getLastMessageForConversation(
            withId: model.id) { (result) in
            defer {
                group.leave()
            }
            switch result {
            case .success(let message):
                lastMessageText = message.messageText
                lastMessageTimestamp = message.timestamp
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            guard let nickname = nickname, let lastMessageText = lastMessageText,
                  let lastMessageTimestamp = lastMessageTimestamp else {
                completion(nil)
                return
            }
            
            let conversationViewModel = ConversationViewModel(
                image: profileImage,
                name: nickname,
                lastMessageText: lastMessageText,
                lastMessageTimestamp: lastMessageTimestamp,
                unread: false
            )
            completion(conversationViewModel)
        }))

    }
}
