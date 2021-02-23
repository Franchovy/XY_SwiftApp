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
    
    private let startConversationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 19)
        label.textColor = UIColor(named: "tintColor")
        label.alpha = 0.7
        return label
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
        
        view.backgroundColor = UIColor(named:"Black")
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModels.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: viewModels.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        let typeViewHeight:CGFloat = 60
        
        tableView.frame = view.bounds.inset(by: UIEdgeInsets(top: view.safeAreaInsets.top, left: 0, bottom: 60 + view.safeAreaInsets.bottom, right: 0))
        
        closeButton.frame = CGRect(
            x: 5,
            y: 5,
            width: 25,
            height: 25
        )
        
        typeView.frame = CGRect(
            x: 0,
            y: view.height - typeViewHeight - view.safeAreaInsets.bottom,
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
        
        setUpNavigationTitle()
        tableView.reloadData()
    }
    
    func configureForNewConversation(with viewModel: ConversationViewModel) {
        // Show color choice
        otherUserId = viewModel.otherUserId
        self.conversationViewModel = viewModel
        setUpNavigationTitle()
        
        view.addSubview(startConversationLabel)
        startConversationLabel.text = "Start a conversation with \(viewModel.name)!"
        startConversationLabel.sizeToFit()
        startConversationLabel.frame = CGRect(
            x: (view.width - startConversationLabel.width)/2,
            y: view.height/3,
            width: startConversationLabel.width,
            height: startConversationLabel.height
        )
        startConversationLabel.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.startConversationLabel.alpha = 0.7
        }
        
    }
    
    // MARK: - Obj-C Functions
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              typeView.frame.origin.y == view.height - view.safeAreaInsets.bottom - 60
              else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        tableView.contentInset.bottom = keyboardSize.height + 60
        typeView.frame.origin.y -= keyboardSize.height - 60
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        tableView.contentInset.bottom = 60
        typeView.frame.origin.y = view.height - view.safeAreaInsets.bottom - 60
    }
    
    @objc func closeButtonPressed() {
        delegate?.didTapClose(vc: self)
    }
    
    // MARK: - Private Functions
    
    private func setUpNavigationTitle() {
        guard let conversationViewModel = conversationViewModel else {
            print("Initialise conversationViewModel before setting up navigation title view.")
            return
        }
        
        let navigationView = UIView()
        let label = UILabel()
        label.text = conversationViewModel.name
        label.font = UIFont(name: "Raleway-ExtraBold", size: 24)
        label.textColor = UIColor(named: "tintColor")
        label.sizeToFit()
        navigationView.addSubview(label)
        
        let profileImageView = UIImageView(image: conversationViewModel.image)
        profileImageView.contentMode = .scaleAspectFill
        
        let size:CGFloat = 30
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = size/2
        navigationView.addSubview(profileImageView)
        
        navigationItem.titleView = navigationView
        
        label.frame = CGRect(
            x: (navigationView.width - label.width)/2,
            y: (navigationView.height - label.height)/2,
            width: label.width,
            height: label.height
        )
        
        profileImageView.frame = CGRect(
            x: label.left - 10 - size,
            y: label.top,
            width: size,
            height: size
        )
    }
    
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
        guard let conversationViewModel = conversationViewModel else {
            return
        }
        
        if conversationViewModel.new {
            let newConversationViewModel = ConversationViewModelBuilder.begin(with: conversationViewModel, message: text)
            self.conversationViewModel = newConversationViewModel
            
            UIView.animate(withDuration: 0.5) {
                self.startConversationLabel.alpha = 0.0
            }
            
            ConversationFirestoreManager.shared.startConversation(
                with: newConversationViewModel) { (result) in
                switch result {
                case .success(let conversationModel):
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
                                
                                self.tableView.scrollToRow(at: IndexPath(row: self.viewModels.count-1, section: 0), at: .bottom, animated: true)
                            case .failure(let error):
                                print(error)
                            }
                        }
                    
                    
                case .failure(let error):
                    print(error)
                }
            }
        } else {
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
                    
                    self.tableView.scrollToRow(at: IndexPath(row: self.viewModels.count-1, section: 0), at: .bottom, animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
