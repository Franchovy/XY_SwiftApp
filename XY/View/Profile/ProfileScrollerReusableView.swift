//
//  ProfileScrollerReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 30/01/2021.
//

import UIKit

class ProfileScrollerReusableView: UICollectionReusableView {
    
    static let identifier = "ProfileScrollerReusableView"
    
    let horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    let topBar: UIView = {
        let view = UIView()
        return view
    }()
    
    let control: UISegmentedControl = {
        let control = UISegmentedControl()
        
        control.selectedSegmentIndex = 0
        control.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        control.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        control.backgroundColor = .clear
        control.selectedSegmentTintColor = .clear
        
        return control
    }()
    
    private var viewControllers = [UIViewController]()
    
    private var previousYScrollOffset:CGFloat = 0
    
    private var isOwn = false
    
    //MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layer.cornerRadius = 15
        
        let profileViewController = ProfileHeaderViewController()
        profileViewController.delegate = self
        horizontalScrollView.addSubview(profileViewController.view)
        viewControllers.append(profileViewController)
        control.insertSegment(
            with: UIImage(named: "profile_profile_icon")?.withTintColor(UIColor(0xF6F6F6)),
            at: 0,
            animated: false
        )
        
        let settingsViewController = ProfileHeaderSettingsViewController()
        settingsViewController.delegate = self
        horizontalScrollView.addSubview(settingsViewController.view)
        viewControllers.append(settingsViewController)
        control.insertSegment(
            with: UIImage(named: "profile_settings_icon")?.withTintColor(UIColor(0xB6B6B6)),
            at: viewControllers.count - 1,
            animated: false
        )
            
        addSubview(horizontalScrollView)
        addSubview(topBar)
        topBar.addSubview(control)

        
        horizontalScrollView.contentInsetAdjustmentBehavior = .never
        horizontalScrollView.delegate = self
    
        setUpHeaderButtons()
        setControlSegmentColor(forIndex: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()

        horizontalScrollView.frame = bounds

        var topBarHeight: CGFloat = 30
        topBar.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: topBarHeight
        )
        
        control.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: topBarHeight
        )
        
        horizontalScrollView.contentSize = CGSize(
            width: width * CGFloat(viewControllers.count),
            height: height
        )
        
        for i in 0...viewControllers.count-1 {
            let viewController = viewControllers[i]
            viewController.view.frame = CGRect(
                x: horizontalScrollView.width * CGFloat(i),
                y: topBarHeight,
                width: horizontalScrollView.width,
                height: horizontalScrollView.height - topBarHeight
            )
        }
    }
    
    //MARK: - Obj-C Functions
    
    @objc private func didChangeSegmentControl(_ sender: UISegmentedControl) {
        horizontalScrollView.setContentOffset(CGPoint(x: width * CGFloat(sender.selectedSegmentIndex),
                                                      y: 0),
                                              animated: true)
    }
    
    @objc private func didTapAnywhere() {
        guard let profileViewController = viewControllers[0] as? ProfileHeaderViewController else {
            return
        }
        profileViewController.didTapAnywhere()
    }
    //MARK: - Public functions
    
    func setUpHeaderButtons() {
        control.addTarget(self, action: #selector(didChangeSegmentControl(_:)), for: .valueChanged)
    }
    
    public func setIsOwnProfile(isOwn: Bool) {
        self.isOwn = isOwn
        
        if !isOwn {
            // Remove settings segment
            control.removeSegment(at: control.numberOfSegments-1, animated: false)
        }
    }
    
    public func configure(with viewModel: ProfileViewModel) {
        guard let profileViewController = viewControllers[0] as? ProfileHeaderViewController else {
            return
        }
//        profileViewController.configure(with: viewModel)
                
        isOwn = viewModel.userId == AuthManager.shared.userId
        
        if isOwn {
            let conversationsViewController = ProfileHeaderConversationsViewController()
            horizontalScrollView.addSubview(conversationsViewController.view)
            viewControllers.insert(conversationsViewController, at: 1)

            control.insertSegment(
                with: UIImage(named: "profile_conversations_icon")?.withTintColor(UIColor(0xB6B6B6)),
                at: 1,
                animated: false
            )
            
            // Fetch all of this user's conversations
            ConversationFirestoreManager.shared.getConversations { (result) in
                switch result {
                case .success(let conversationModels):
                    var conversations = [ConversationViewModel]()
                    
                    for model in conversationModels {
                        ConversationViewModelBuilder.build(from: model) { (viewModel) in
                            
                            if let viewModel = viewModel {
                                conversations.append(viewModel)
                            }
                            if conversations.count == conversationModels.count {
                                conversationsViewController.configure(with: conversations)
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
            conversationsViewController.delegate = self
            
        } else {
            let chatViewController = ProfileHeaderChatViewController()
            horizontalScrollView.addSubview(chatViewController.view)
            viewControllers.insert(chatViewController, at: 1)
            control.insertSegment(
                with: UIImage(named: "profile_conversations_icon")?.withTintColor(UIColor(0xB6B6B6)),
                at: 1,
                animated: false
            )
            
            guard let userId = viewModel.userId else {
                return
            }
            // Fetch conversation
            FirebaseDownload.getConversationWithUser(
                otherUserId: userId) { (result) in
                switch result {
                case .success(let conversationModel):
                    if let conversationModel = conversationModel {
                        ChatFirestoreManager.shared.getMessagesForConversation(
                            withId: conversationModel.id) { (result) in
                            switch result {
                            case .success(let messageModels):
                                let messageViewModels: [MessageViewModel] = messageModels.map({ (model) in
                                    return MessageViewModel(
                                        text: model.messageText,
                                        timestamp: model.timestamp,
                                        nickname: viewModel.nickname,
                                        senderIsSelf: model.senderId == AuthManager.shared.userId
                                    )
                                })
                                let conversationViewModel = ConversationViewModel(
                                    id: conversationModel.id,
                                    otherUserId: userId,
                                    image: viewModel.profileImage,
                                    name: viewModel.nickname,
                                    lastMessageText: messageModels.last!.messageText,
                                    lastMessageTimestamp: messageModels.last!.timestamp,
                                    unread: false
                                )
                                
                                chatViewController.configure(
                                    with: conversationViewModel,
                                    chatViewModels: messageViewModels
                                )
                            case .failure(let error):
                                print(error)
                            }
                        }
                    } else {
                        chatViewController.configureForNewConversation(with: userId)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        setNeedsLayout()
        
        setControlSegmentColor(forIndex: 0)
    }
    
    public func getProfileDelegate() -> ProfileViewModelDelegate {
        guard let profileViewController = viewControllers[0] as? ProfileHeaderViewController else {
            fatalError()
        }
        return profileViewController
    }
    
    //MARK: - Private functions
    
    private func insertViewController(atIndex index: Int, vc: UIViewController, withIcon icon: UIImage, navigateToNewVC: Bool) {
        horizontalScrollView.addSubview(vc.view)
        viewControllers.insert(vc, at: index)
        
        control.insertSegment(
            with: icon.withTintColor(UIColor(0xB6B6B6)),
            at: index,
            animated: true
        )
        
        setNeedsLayout()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.2) {
                self.horizontalScrollView.contentOffset = CGPoint(x: vc.view.frame.origin.x, y: 0)
            }
        }
    }
    
    private func removeViewController(atIndex index: Int, vc: UIViewController) {
        
        if control.selectedSegmentIndex == index {
            control.selectedSegmentIndex = index - 1
        }
        
        UIView.animate(withDuration: 0.2) {
            self.horizontalScrollView.contentOffset = CGPoint(x: self.viewControllers[index - 1].view.frame.origin.x, y: 0)
            
            self.setNeedsLayout()
        } completion: { (done) in
            if done {
                self.viewControllers.remove(at: index)
                vc.view.removeFromSuperview()
                
                self.control.removeSegment(at: index, animated: true)
            }
        }
    }
    
    private func setControlSegmentColor(forIndex index: Int) {
        
        var selectedIndexColor = UIColor()
        var unselectedIndexColor = UIColor()
        
        selectedIndexColor = UIColor(named: "Light")!
        unselectedIndexColor = UIColor(named: "Dark")!
        
        for index in 0...control.numberOfSegments-1 {
            let image = control.imageForSegment(at: index)
            control.setImage(image?.withTintColor(unselectedIndexColor, renderingMode: .alwaysOriginal), forSegmentAt: index)
        }
        let selectedImage = control.imageForSegment(at: index)?.withTintColor(selectedIndexColor, renderingMode: .alwaysOriginal)
        control.setImage(selectedImage, forSegmentAt: index)
    }
}

//MARK: - ScrollView Delegate

extension ProfileScrollerReusableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        scrollView.contentOffset.y = 0
        let x = scrollView.contentOffset.x
        
        if x <= (width/2) {
            setControlSegmentColor(forIndex: 0)
        } else if x > (width/2), x < (3 * width/2){
            setControlSegmentColor(forIndex: 1)
        } else if x > (3 * width/2) {
            setControlSegmentColor(forIndex: 2)
        }
        
    }
}

//MARK: - Profile Header Delegate

extension ProfileScrollerReusableView : ProfileHeaderViewControllerDelegate {
    func didEnterEditMode() {
        horizontalScrollView.isScrollEnabled = false
    }
    
    func didExitEditMode() {
        horizontalScrollView.isScrollEnabled = true
    }
}

//MARK: - Profile Settings Delegate

extension ProfileScrollerReusableView : ProfileHeaderSettingsViewControllerDelegate {
    func didLogOut() {
        guard let superview = superview else {
            return
        }
        print(superview)
        guard let superviewController = superview.parentContainerViewController() as? TabBarViewController else {
            return
        }
        print(superviewController)
        
        superviewController.backToLaunch()
    }
}

extension ProfileScrollerReusableView : ProfileConversationsViewControllerDelegate {
    func openConversation(with viewModel: ConversationViewModel) {
        let vc = ProfileHeaderChatViewController()
        vc.delegate = self
        vc.showCloseButton()
        
        ChatFirestoreManager.shared.getMessagesForConversation(
            withId: viewModel.id) { (result) in
            switch result {
            case .success(let messages):
                let chatViewModels = ChatViewModelBuilder.build(for: messages, conversationViewModel: viewModel)
                vc.configure(with: viewModel, chatViewModels: chatViewModels)
            case .failure(let error):
                print(error)
            }
        }
        
        insertViewController(atIndex: 2, vc: vc, withIcon: UIImage(named: "profile_conversations_icon")!, navigateToNewVC: true
        )
    }
}

extension ProfileScrollerReusableView: ProfileChatViewControllerDelegate {
    func didTapClose(vc: ProfileHeaderChatViewController) {
        guard let viewControllerIndex = viewControllers.firstIndex(of: vc) else {
            return
        }
        removeViewController(atIndex: viewControllerIndex, vc: vc)
        
    }
}
