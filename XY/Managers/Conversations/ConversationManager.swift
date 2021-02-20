//
//  ConversationManager.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import Foundation

final class ConversationManager {
    static let shared = ConversationManager()
    private init() { }
    
    func getConversations(completion: @escaping([ConversationViewModel]?) -> Void) {
        ConversationFirestoreManager.shared.getConversations { (result) in
            switch result {
            case .success(let conversationModels):
                
                var conversationViewModels = [ConversationViewModel]()
                
                let dispatchGroup = DispatchGroup()
                for conversationModel in conversationModels {
                    dispatchGroup.enter()
                    
                    ConversationViewModelBuilder.build(from: conversationModel) { (conversationViewModel) in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let conversationViewModel = conversationViewModel {
                            conversationViewModels.append(conversationViewModel)
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main, work: DispatchWorkItem(block: {
                    conversationViewModels.sort(by: { viewModel1, viewModel2 in
                        return viewModel1.lastMessageTimestamp < viewModel2.lastMessageTimestamp
                    })
                    completion(conversationViewModels)
                }))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getConversation(with otherUserId: String, completion: @escaping(ConversationViewModel?, [MessageViewModel]?) -> Void) {
        FirebaseDownload.getConversationWithUser(otherUserId: otherUserId) { (result) in
            switch result {
            case .success(let conversationModel):
                if let conversationModel = conversationModel {
                    
                    var conversationViewModel: ConversationViewModel?
                    var messageViewModels: [MessageViewModel]?
                    
                    ConversationViewModelBuilder.build(from: conversationModel) { (viewModel) in
                        if let viewModel = viewModel {
                            conversationViewModel = viewModel
                            
                            ChatFirestoreManager.shared.getMessagesForConversation(withId: conversationModel.id) { (result) in
                                switch result {
                                case .success(let messages):
                                    messageViewModels = ChatViewModelBuilder.build(for: messages, conversationViewModel: viewModel)
                                    
                                    completion(conversationViewModel, messageViewModels)
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    }
                } else {
                    // New conversation!
                    completion(nil, [])
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getConversationMessages(fromConversationModel viewModel: ConversationViewModel, completion: @escaping([MessageViewModel]?) -> Void) {

        var messageViewModels: [MessageViewModel]?
        
        ChatFirestoreManager.shared.getMessagesForConversation(withId: viewModel.id) { (result) in
            switch result {
            case .success(let messages):
                messageViewModels = ChatViewModelBuilder.build(for: messages, conversationViewModel: viewModel)
                
                completion(messageViewModels)
            case .failure(let error):
                print(error)
            }
        }
    }
}
