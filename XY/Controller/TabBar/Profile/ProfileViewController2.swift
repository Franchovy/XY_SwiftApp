//
//  ProfileViewController2.swift
//  XY
//
//  Created by Maxime Franchot on 19/03/2021.
//

import UIKit
import FaveButton

class ProfileViewController2: UIViewController {
    
    // MARK: - Parent Views
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1.6
        layout.minimumLineSpacing = 1.2
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        
        collectionView.register(ChallengeCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeCollectionViewCell.identifier)
        return collectionView
    }()
    
    // MARK: - Subviews
    
    private let coverImageView = VideoPlayerView()
    
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
        label.layer.shadowRadius = 6
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowColor = UIColor.black.cgColor
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor(named: "XYWhite")?.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 15)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowColor = UIColor.black.cgColor
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor(named: "XYWhite")?.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 15)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowColor = UIColor.black.cgColor
        return button
    }()
    
    private let numSubscribersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 20)
        label.textColor = UIColor(named: "XYWhite")
        label.layer.shadowRadius = 6
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowColor = UIColor.black.cgColor
        return label
    }()
    
    private let subscribersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.textColor = UIColor(named: "XYWhite")
        label.layer.shadowRadius = 6
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowColor = UIColor.black.cgColor
        return label
    }()
    
    private let numRankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 20)
        label.textColor = UIColor(named: "XYWhite")
        label.layer.shadowRadius = 6
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowColor = UIColor.black.cgColor
        return label
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 13)
        label.textColor = UIColor(named: "XYWhite")
        label.layer.shadowRadius = 6
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowColor = UIColor.black.cgColor
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 10)
        label.textColor = UIColor(named: "XYWhite")
        label.layer.shadowRadius = 6
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowColor = UIColor.black.cgColor
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
    
    private let followButton = FollowButton()
    
    private let xpCircle = XPCircleView()
    private let loadingCircle = XPCircleView()
    
    // MARK: - Properties
    
    private var viewModel: NewProfileViewModel?
    private var videoViewModels = [(ChallengeViewModel, ChallengeVideoViewModel)]()
    
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
        xpCircle.isHidden = true
    
        followButton.delegate = self
        
        coverImageView.layer.masksToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let tappedSubsGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSubscribers))
        subscribersLabel.isUserInteractionEnabled = true
        subscribersLabel.addGestureRecognizer(tappedSubsGesture)
        numSubscribersLabel.isUserInteractionEnabled = true
        numSubscribersLabel.addGestureRecognizer(tappedSubsGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xpCircle.setThickness(.thin)
        xpCircle.setColor(UIColor(0x007BF5), labelColor: .white)
        
        loadingCircle.setThickness(.medium)
        
        view.backgroundColor = UIColor(named: "Black")
        
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        
        scrollView.addSubview(coverImageView)
        scrollView.layer.addSublayer(gradientLayer)
        scrollView.addSubview(profileImageView)
        
        scrollView.addSubview(nicknameLabel)
        scrollView.addSubview(xpCircle)
        
        scrollView.addSubview(numSubscribersLabel)
        scrollView.addSubview(subscribersLabel)
        scrollView.addSubview(numRankLabel)
        scrollView.addSubview(rankLabel)
        
        scrollView.addSubview(captionLabel)
        scrollView.addSubview(collectionView)
                
        settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        
        collectionView.backgroundColor = UIColor(named: "Black")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadingCircle.center = profileImageView.center
        
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
        
        scrollView.frame = view.bounds

        coverImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.width * 1.675
        )
        
        captionLabel.sizeToFit()
        captionLabel.frame = CGRect(
            x: (view.width - captionLabel.width)/2,
            y: coverImageView.bottom - 5 - captionLabel.height,
            width: captionLabel.width,
            height: captionLabel.height
        )
        
        subscribersLabel.sizeToFit()
        subscribersLabel.frame = CGRect(
            x: view.width/2 - 50 - subscribersLabel.width/2,
            y: captionLabel.top - 6 - subscribersLabel.height,
            width: subscribersLabel.width,
            height: subscribersLabel.height
        )
        
        rankLabel.sizeToFit()
        rankLabel.frame = CGRect(
            x: view.width/2 + 50,
            y: captionLabel.top - 6 - rankLabel.height,
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
        
        var buttonTopY: CGFloat!
        let buttonSize = CGSize(width: 93, height: 27)
        if viewModel?.userId == AuthManager.shared.userId {
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
            
            buttonTopY = settingsButton.top
        } else {
            followButton.frame = CGRect(
                x: (view.width - buttonSize.width)/2,
                y: numSubscribersLabel.top - 10 - buttonSize.height,
                width: buttonSize.width,
                height: buttonSize.height
            )
            
            buttonTopY = followButton.top
        }
        
        let xpCircleSize:CGFloat = 25
        
        nicknameLabel.sizeToFit()
        nicknameLabel.frame = CGRect(
            x: (view.width - nicknameLabel.width)/2 - (xpCircleSize + 5)/2,
            y: buttonTopY - 13 - nicknameLabel.height,
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
        
        loadingCircle.frame = profileImageView.frame
        
        let gradientLayerHeight:CGFloat = coverImageView.height - profileImageView.top - profileImageSize/2
        gradientLayer.frame = CGRect(
            x: 0,
            y: coverImageView.height - gradientLayerHeight,
            width: view.width,
            height: gradientLayerHeight + 10
        )
        
        collectionView.frame = CGRect(
            x: 0,
            y: coverImageView.bottom,
            width: view.width,
            height: collectionView.contentSize.height
        )
        
        scrollView.contentSize.height = collectionView.bottom
    }
    
    // MARK: - Public Functions
    
    var fetchingVideos = false
    public func configure(with viewModel: NewProfileViewModel) {
        self.viewModel = viewModel
        numSubscribersLabel.text = String(describing: viewModel.numFollowers)
        if let rank = viewModel.rank {
            numRankLabel.text = String(describing: rank)
        } else if numRankLabel.text == nil {
            numRankLabel.text = "None"
        }
        
        subscribersLabel.text = viewModel.numFollowers == 1 ? "Subscriber" : "Subscribers"
        rankLabel.text = "Rank"
        
        if viewModel.userId != AuthManager.shared.userId {
            followButton.configure(for: viewModel.relationshipType, otherUserID: viewModel.userId)
        }
        
        nicknameLabel.text = viewModel.nickname
        captionLabel.text = viewModel.caption
        
        if viewModel.profileImage != nil {
            profileImageView.image = viewModel.profileImage
        }
        
        if !fetchingVideos && videoViewModels.count == 0 {
            fetchingVideos = true
            
            ChallengesFirestoreManager.shared.getVideosByUser(userID: viewModel.userId) { pairs in
                if let pairs = pairs {
                    
                    if let pair = pairs.first {
                        StorageManager.shared.downloadVideo(videoId: pair.1.videoRef, containerId: nil) { (result) in
                            switch result {
                            case .success(let url):
                                self.coverImageView.setUpVideo(videoURL: url, withRate: 1.0, audioEnable: false)
                                self.coverImageView.setCornerRadius(5)
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                    
                    for pair in pairs {
                        ChallengesViewModelBuilder.buildChallengeAndVideo(
                            from: pair.1,
                            challengeModel: pair.0,
                            withThumbnailImage: true,
                            completion: { (pair) in
                                if let pair = pair {
                                    self.videoViewModels.append(pair)
                                    
                                    if self.videoViewModels.count == pairs.count {
                                        self.collectionView.reloadData()
                                        self.fetchingVideos = false
                                    }
                                }
                            })
                    }
                }
            }
        }
        
        let progress:CGFloat = CGFloat(viewModel.xp) / CGFloat(XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user))
        xpCircle.setLabel(String(describing: viewModel.level))
        xpCircle.setProgress(progress)
    }
    
    public func onLoadedProfile() {
        loadingCircle.removeFromSuperview()
        
        xpCircle.isHidden = false
        
        guard let userID = viewModel?.userId else {
            return
        }
        
        if userID == AuthManager.shared.userId {
            scrollView.addSubview(settingsButton)
            scrollView.addSubview(editButton)
        } else {
            scrollView.addSubview(followButton)
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
        vc.configure()
        vc.onClose = {
            guard let ownProfile = ProfileManager.shared.ownProfile else {
                return
            }
            ProfileViewModelBuilder.build(with: ownProfile, withUserModel: nil, fetchingProfileImage: true, fetchingCoverImage: false) { (profileViewModel) in
                if let profileViewModel = profileViewModel {
                    self.configure(with: profileViewModel)
                }
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapSettingsButton() {
        let vc = ProfileHeaderSettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapSubscribers() {
        guard let viewModel = viewModel else {
            return
        }

        let vc = SubscribersViewController()
        vc.configure(userId: viewModel.userId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setUpNavBar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
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
    }
}

extension ProfileViewController2 : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChallengeCollectionViewCell.identifier,
            for: indexPath
        ) as? ChallengeCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(viewModel: videoViewModels[indexPath.row].0, videoViewModel: videoViewModels[indexPath.row].1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSize = view.width / 3 - 1.6
        return CGSize(width: horizontalSize, height: horizontalSize * 1.626)
    }
}
