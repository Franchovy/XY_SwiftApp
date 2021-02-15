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

        let chatViewController = ProfileHeaderChatViewController()
        horizontalScrollView.addSubview(chatViewController.view)
        viewControllers.append(chatViewController)
        control.insertSegment(
            with: UIImage(named: "profile_conversations_icon")?.withTintColor(UIColor(0xB6B6B6)),
            at: viewControllers.count - 1,
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

        horizontalScrollView.contentSize = CGSize(
            width: width * CGFloat(viewControllers.count),
            height: height
        )
        
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
//        control.isHidden = !isOwn
        self.isOwn = isOwn
        
        if !isOwn {
            // Remove settings segment
            control.removeSegment(at: control.numberOfSegments-1, animated: false)
        }
//        horizontalScrollView.isScrollEnabled = isOwn
    }
    
    public func configure(with viewModel: ProfileViewModel) {
        guard let profileViewController = viewControllers[0] as? ProfileHeaderViewController else {
            return
        }
        profileViewController.configure(with: viewModel)
        
        if isOwn {
            guard let conversationsViewController = viewControllers[1] as? ProfileHeaderConversationsViewController else {
                return
            }
            // Fetch all of this user's conversations
            
        } else {
            guard let chatViewController = viewControllers[1] as? ProfileHeaderChatViewController,
                  let userId = viewModel.userId else {
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
                        
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    public func getProfileDelegate() -> ProfileViewModelDelegate {
        guard let profileViewController = viewControllers[0] as? ProfileHeaderViewController else {
            fatalError()
        }
        return profileViewController
    }
    
    //MARK: - Private functions
    
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
        
        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x <= (width/2) {
            setControlSegmentColor(forIndex: 0)
        } else if scrollView.contentOffset.x > (width/2) && scrollView.contentOffset.x < (3 * width/2){
            setControlSegmentColor(forIndex: 1)
        } else if scrollView.contentOffset.x > (3 * width/2) {
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
