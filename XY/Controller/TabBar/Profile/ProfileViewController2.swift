//
//  ProfileViewController2.swift
//  XY
//
//  Created by Maxime Franchot on 19/03/2021.
//

import UIKit

class ProfileViewController2: UIViewController {
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 25)
        label.textColor = UIColor(named: "XYWhite")
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor(named: "XYWhite")?.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 15)
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor(named: "XYWhite")?.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 15)
        return button
    }()
    
    private let numSubscribersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 20)
        label.textColor = UIColor(named: "XYWhite")
        return label
    }()
    
    private let subscribersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.textColor = UIColor(named: "XYWhite")
        return label
    }()
    
    private let numRankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 20)
        label.textColor = UIColor(named: "XYWhite")
        return label
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.textColor = UIColor(named: "XYWhite")
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 10)
        label.textColor = UIColor(named: "XYWhite")
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private let xpCircle = XPCircleView()
    
    private let loadingCircle = XPCircleView()
    
    private var viewModel: NewProfileViewModel?
    
    // MARK: - Initialisers
    
    init(profileId: String) {
        super.init(nibName: nil, bundle: nil)
        
        ProfileFirestoreManager.shared.getProfile(forProfileID: profileId) { (profileModel) in
            if let profileModel = profileModel {
                ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                    if let profileViewModel = profileViewModel {
                        self.configure(with: profileViewModel)
                        self.onLoadedProfile()
                    }
                }
            }
        }
        
        commonInit()
    }
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        
        ProfileFirestoreManager.shared.getProfileID(forUserID: userId) { (profileId, error) in
            if let error = error {
                print(error)
            } else if let profileId = profileId {
                ProfileFirestoreManager.shared.getProfile(forProfileID: profileId) { (profileModel) in
                    if let profileModel = profileModel {
                        ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                            if let profileViewModel = profileViewModel {
                                self.configure(with: profileViewModel)
                                self.onLoadedProfile()
                            }
                        }
                    }
                }
            }
        }
        
        commonInit()
    }
    
    private func commonInit() {
        view.addSubview(loadingCircle)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xpCircle.setThickness(.thin)
        xpCircle.setColor(UIColor(0x007BF5))
        
        loadingCircle.frame.size = CGSize(width: 50, height: 50)
        loadingCircle.center = view.center
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(coverImageView)
        view.layer.addSublayer(gradientLayer)
        view.addSubview(profileImageView)
        
        view.addSubview(nicknameLabel)
        view.addSubview(xpCircle)
        
        view.addSubview(settingsButton)
        view.addSubview(editButton)
        
        view.addSubview(numSubscribersLabel)
        view.addSubview(subscribersLabel)
        view.addSubview(numRankLabel)
        view.addSubview(rankLabel)
        
        view.addSubview(descriptionLabel)
                
        settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var loadingCircleProgress:CGFloat = 0.1
        loadingCircle.setProgress(loadingCircleProgress)
        
        while loadingCircleProgress < 1.0 {
            let time = Double.random(in: 0.5...2.5)
            let increment:CGFloat = CGFloat.random(in: 0.1...0.3)
            
            loadingCircleProgress += min(increment, 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now()+time) {
                
                self.loadingCircle.animateSetProgress(loadingCircleProgress)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let viewModel = viewModel {
            ProfileManager.shared.cancelListenerFor(userId: viewModel.userId)
        }
        StorageManager.shared.cancelCurrentDownloadTasks()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        coverImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.width * 1.675
        )
        
        descriptionLabel.sizeToFit()
        descriptionLabel.frame = CGRect(
            x: (view.width - descriptionLabel.width)/2,
            y: coverImageView.bottom - 1 - descriptionLabel.height,
            width: descriptionLabel.width,
            height: descriptionLabel.height
        )
        
        subscribersLabel.sizeToFit()
        subscribersLabel.frame = CGRect(
            x: view.width/2 - subscribersLabel.width - 25,
            y: descriptionLabel.top - 6 - subscribersLabel.height,
            width: subscribersLabel.width,
            height: subscribersLabel.height
        )
        
        rankLabel.sizeToFit()
        rankLabel.frame = CGRect(
            x: view.width/2 + 25,
            y: descriptionLabel.top - 6 - rankLabel.height,
            width: rankLabel.width,
            height: rankLabel.height
        )
        
        numSubscribersLabel.sizeToFit()
        numSubscribersLabel.frame = CGRect(
            x: subscribersLabel.center.x - numSubscribersLabel.width/2,
            y: subscribersLabel.top - numSubscribersLabel.height,
            width: numSubscribersLabel.width,
            height: numSubscribersLabel.height
        )
        
        numRankLabel.sizeToFit()
        numRankLabel.frame = CGRect(
            x: rankLabel.center.x - numRankLabel.width/2,
            y: rankLabel.top - numRankLabel.height,
            width: numRankLabel.width,
            height: numRankLabel.height
        )
        
        let buttonSize = CGSize(width: 93, height: 27)
        editButton.frame = CGRect(
            x: view.width/2 - 2.5 - buttonSize.width,
            y: numSubscribersLabel.top - 10 - buttonSize.height,
            width: buttonSize.width,
            height: buttonSize.height
        )
        editButton.layer.cornerRadius = buttonSize.height/2
        
        settingsButton.frame = CGRect(
            x: view.width/2 + 2.5,
            y: numSubscribersLabel.top - 10 - buttonSize.height,
            width: buttonSize.width,
            height: buttonSize.height
        )
        settingsButton.layer.cornerRadius = buttonSize.height/2
        
        let xpCircleSize:CGFloat = 25
        
        nicknameLabel.sizeToFit()
        nicknameLabel.frame = CGRect(
            x: (view.width - nicknameLabel.width)/2 - (xpCircleSize + 5)/2,
            y: settingsButton.top - 13 - nicknameLabel.height,
            width: nicknameLabel.width,
            height: nicknameLabel.height
        )
        
        xpCircle.frame = CGRect(
            x: nicknameLabel.right + 8,
            y: nicknameLabel.top + 4,
            width: xpCircleSize,
            height: xpCircleSize
        )
        
        let profileImageSize: CGFloat = 100
        profileImageView.frame = CGRect(
            x: (view.width - profileImageSize)/2,
            y: nicknameLabel.top - 15.11 - profileImageSize,
            width: profileImageSize,
            height: profileImageSize
        )
        profileImageView.layer.cornerRadius = profileImageSize/2
        
        let gradientLayerHeight:CGFloat = view.height - profileImageView.center.x
        gradientLayer.frame = CGRect(
            x: 0,
            y: view.height - gradientLayerHeight,
            width: view.width,
            height: gradientLayerHeight
        )
        
    }
    
    // MARK: - Public Functions
    
    public func configure(with viewModel: NewProfileViewModel) {
        self.viewModel = viewModel
        numSubscribersLabel.text = String(describing: viewModel.numFollowers)
        numRankLabel.text = String(describing: viewModel.rank ?? 0)
        
        subscribersLabel.text = viewModel.numFollowers == 1 ? "Subscriber" : "Subscribers"
        rankLabel.text = "Rank"
        
        nicknameLabel.text = viewModel.nickname
        descriptionLabel.text = viewModel.caption
        
        profileImageView.image = viewModel.profileImage
        coverImageView.image = viewModel.coverImage
        
        let progress:CGFloat = CGFloat(viewModel.xp) / CGFloat(XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user))
        xpCircle.setLabel(String(describing: viewModel.level))
        xpCircle.setProgress(progress)
    }
    
    public func onLoadedProfile() {
        loadingCircle.removeFromSuperview()
        
        guard let userID = viewModel?.userId else {
            return
        }
        ProfileManager.shared.listenToProfileUpdatesFor(userId: userID) { viewModel in
            if let viewModel = viewModel {
                self.configure(with: viewModel)
            }
        }
    }
    
    public func setHeroID(forProfileImage id: String) {
        isHeroEnabled = true
        
        profileImageView.heroID = id
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func openChatButtonPressed() {
        guard let selfId = AuthManager.shared.userId, let viewModel = viewModel else {
            return
        }
        if viewModel.userId == selfId {
            let vc = ProfileHeaderConversationsViewController()
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            ConversationManager.shared.getConversations() { conversationViewModels in
                if let conversationViewModels = conversationViewModels {
                    vc.configure(with: conversationViewModels)
                }
            }
            
        } else {
            let vc = ProfileHeaderChatViewController()
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            ConversationManager.shared.getConversation(with: viewModel.userId) { conversationViewModel, messageViewModels in
                if let conversationViewModel = conversationViewModel, let messageViewModels = messageViewModels {
                    vc.configure(with: conversationViewModel, chatViewModels: messageViewModels)
                } else if conversationViewModel == nil, messageViewModels?.count == 0 {
                    let newConversationViewModel = ConversationViewModelBuilder.new(with: viewModel)
                    vc.configureForNewConversation(with: newConversationViewModel)
                }
                
            }
        }
    }
    
    // MARK: - Private Functions
    
    @objc private func didTapEditButton() {
        let vc = EditProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapSettingsButton() {
        let vc = ProfileHeaderSettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setUpNavBar() {
        guard let viewModel = viewModel else {
            return
        }
        
        if viewModel.userId == AuthManager.shared.userId {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "profile_conversations_icon")?.withRenderingMode(.alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(openChatButtonPressed)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "profile_chat_icon")?.withRenderingMode(.alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(openChatButtonPressed)
            )
        }
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
}

