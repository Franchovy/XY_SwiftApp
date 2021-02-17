//
//  ProfileHeaderChatViewController.swift
//  XY
//
//  Created by Maxime Franchot on 11/02/2021.
//

import UIKit

protocol ProfileChatViewControllerDelegate {
    func didTapClose(vc: ProfileHeaderChatViewController)
}

class ProfileHeaderChatViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        tableView.allowsMultipleSelection = true
        tableView.separatorStyle = .none
        tableView.register(ChatBubbleTableViewCell.self, forCellReuseIdentifier: ChatBubbleTableViewCell.identifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.alwaysBounceVertical = true
        tableView.bounces = true
        return tableView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let typeView = TypeView()
    
    var delegate: ProfileChatViewControllerDelegate?
    
    var conversationViewModel: ConversationViewModel?
    var viewModels = [MessageViewModel]()
    
    var newConversation = false
    var otherUserId: String?
    
    // MARK: - Initialisers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        typeView.delegate = self
        
        view.addSubview(tableView)
                
        view.addSubview(typeView)
        view.addSubview(closeButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLayoutSubviews() {
        
        let typeViewHeight:CGFloat = 40
        
        tableView.frame = view.bounds.inset(by: UIEdgeInsets(top: 25, left: 0, bottom: 40, right: 0))
        
        closeButton.frame = CGRect(
            x: 5,
            y: 5,
            width: 25,
            height: 25
        )
        
        typeView.frame = CGRect(
            x: 0,
            y: view.height - typeViewHeight,
            width: view.width,
            height: typeViewHeight
        )
    }
    
    // MARK: - Public functions
    
    func showCloseButton() {
        closeButton.isHidden = false
    }
    
    func configure(with conversationViewModel: ConversationViewModel, chatViewModels: [MessageViewModel]) {
        viewModels = chatViewModels
        self.otherUserId = conversationViewModel.otherUserId
        self.conversationViewModel = conversationViewModel
        tableView.reloadData()
    }
    
    func configureForNewConversation(with userId: String) {
        // Show color choice
        otherUserId = userId
        newConversation = true
    }
    
    // MARK: - Obj-C Functions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        typeView.frame.origin.y -= keyboardSize.height - 40 - view.top
//        tableView.frame.size.height -= tableView.bottom - typeView.top
        
//        tappedAnywhereGesture.isEnabled = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        tappedAnywhereGesture.isEnabled = false
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        typeView.frame.origin.y = view.height - 40
    }
    
    @objc func closeButtonPressed() {
        delegate?.didTapClose(vc: self)
    }
    
    // MARK: - Private Functions
    
    private func sendPushNotificationForMessage(message: Message) {
        
        guard let otherUserId = otherUserId else {
            fatalError("Please set other user id")
        }
        // Send push notification
        let pushNotificationSender = PushNotificationSender()
        pushNotificationSender.sendPushNotification(to: otherUserId, title: ProfileManager.shared.ownProfile!.nickname, body: message.messageText)
        
    }

}

extension ProfileHeaderChatViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleTableViewCell.identifier) as? ChatBubbleTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    
}

extension ProfileHeaderChatViewController : TypeViewDelegate {
    func emojiButtonPressed() {
        
    }
    
    func imageButtonPressed() {
        
    }
    
    func sendButtonPressed(text: String) {
        if newConversation {
            guard let otherUserId = otherUserId else {
                fatalError("other User ID not set!")
            }
            
            ConversationFirestoreManager.shared.startConversation(
                withUser: otherUserId,
                message: text) { (result) in
                switch result {
                case .success(let conversationModel):
                    
                    ConversationViewModelBuilder.build(from: conversationModel) { (conversationViewModel) in
                        if let conversationViewModel = conversationViewModel {
                            // Subscribe to messages
                            ChatFirestoreManager.shared.getMessagesForConversation(withId: conversationModel.id) { (result) in
                                switch result {
                                case .success(let messages):
                                    let messageViewModels = ChatViewModelBuilder.build(
                                        for: messages,
                                        conversationViewModel: conversationViewModel
                                    )
                                    self.conversationViewModel = conversationViewModel
                                    self.viewModels = messageViewModels
                                    self.tableView.reloadData()
                                    
                                    
                                    
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            guard let conversationViewModel = conversationViewModel else {
                fatalError("Conversation ViewModel not configured correctly")
            }
            // Send message normally
            ChatFirestoreManager.shared.sendChat(
                conversationID: conversationViewModel.id,
                messageText: text) { (result) in
                switch result {
                case .success(let messageID):
                    let newMessageModel = Message(senderId: AuthManager.shared.userId ?? "", messageText: text, timestamp: Date())
                    let newMessageViewModel = ChatViewModelBuilder.build(for: [newMessageModel], conversationViewModel: conversationViewModel)
                    
                    self.sendPushNotificationForMessage(message: newMessageModel)
                    
                    self.viewModels.append(contentsOf: newMessageViewModel)
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
