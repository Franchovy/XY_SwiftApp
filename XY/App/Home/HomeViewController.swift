//
//  HomeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class HomeViewController: UIViewController {
        
    // MARK: - UI Properties
    
    private let friendsCollectionView = FriendsCollectionView()
    
    private let challengesLabel = Label("Your Challenges", style: .title)
    private let challengesCollectionView = ChallengeCardsCollectionView()
    
    private let challengesDataSource = ChallengesDataSource()
    private let friendsDataSource = FriendsDataSource()
    
    private let welcomeGradientLabel = GradientLabel(text: "Welcome To XY!", fontSize: 40, gradientColours: Global.xyGradient)
    private let welcomeTextLabel = Label("Finish setting up your profile to begin playing the game.", style: .body, fontSize: 20)
    
    private let noChallengesLabel = Label("You have no challenges.", style: .body, fontSize: 18)
    private let createChallengeButton = Button(title: "Create new", style: .roundButtonBorder(gradient: Global.xyGradient), font: UIFont(name: "Raleway-Heavy", size: 26))
    
    private let skinnerBox = SkinnerBox()
    private let skinnerBoxCompletionCircle = XPCircleView()
    
    // MARK: - Reference properties
    
    var displayedTaskNumber: Int!
    var taskNumber: Int!
    
    var isVisible = false
    var setup = false
    var skinnerBoxMode = false
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        NavigationControlManager.mainViewController = self
        
        view.backgroundColor = UIColor(named: "XYBackground")
        challengesCollectionView.dataSource = challengesDataSource
        friendsCollectionView.dataSource = friendsDataSource
        friendsDataSource.showEditProfile = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(friendsCollectionView)
        view.addSubview(challengesLabel)
        view.addSubview(challengesCollectionView)
        view.addSubview(noChallengesLabel)
        view.addSubview(createChallengeButton)
        
        SkinnerBoxManager.shared.load()
        if SkinnerBoxManager.shared.taskNumber == SkinnerBoxManager.shared.numTasks {
            skinnerBoxMode = false
            
            configureForNotSkinnerBox()
            
        } else {
            skinnerBoxMode = true
            
            view.addSubview(welcomeGradientLabel)
            view.addSubview(welcomeTextLabel)
            view.addSubview(skinnerBox)
            view.addSubview(skinnerBoxCompletionCircle)
            
            skinnerBoxCompletionCircle.setColor(SkinnerBoxManager.shared.taskNumber < SkinnerBoxManager.shared.numTasks ? .XYRed : .XYGreen)
            skinnerBoxCompletionCircle.setThickness(.medium)
            
            self.taskNumber = SkinnerBoxManager.shared.taskNumber
            self.displayedTaskNumber = taskNumber
    
            skinnerBoxCompletionCircle.setProgress( max(CGFloat(SkinnerBoxManager.shared.taskNumber) / CGFloat(SkinnerBoxManager.shared.uncompletedTaskDescriptions.count), 0.01))
            skinnerBoxCompletionCircle.setLabel("\(SkinnerBoxManager.shared.taskNumber)/\(SkinnerBoxManager.shared.numTasks)")
            SkinnerBoxManager.shared.delegate = self
            
            configureForSkinnerBox()
        }
        
        welcomeTextLabel.numberOfLines = 0
        welcomeTextLabel.textAlignment = .center
        
        createChallengeButton.addTarget(self, action: #selector(tappedCreateChallenge), for: .touchUpInside)
            
        let logoView = UIImageView(image: UIImage(named: "XYLogo"))
        logoView.contentMode = .scaleAspectFit
        logoView.frame.size = CGSize(width: 53.36, height: 28.4)
        
        navigationItem.titleView = logoView
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "magnifyingglass")?.withTintColor(UIColor(named: "XYTint")!, renderingMode: .alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(tappedSearch)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "bell.fill")?.withTintColor(UIColor(named: "XYTint")!, renderingMode: .alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(tappedNotifications)
            )
        ]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        challengesDataSource.reload()
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.configureBackgroundStyle(.visible)
        configureBackButton(.backButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isVisible = true
        
        if !setup {
            initialiseSetup()
            setup = true
        }
        
        if SkinnerBoxManager.shared.taskNumber == SkinnerBoxManager.shared.numTasks {
            PushNotificationManager.shared.shouldAskForPermissions() { shouldPrompt in
                if shouldPrompt {
                    DispatchQueue.main.async {
                        self.showNotificationsPrompt()
                    }
                }
            }
        }
        
        guard displayedTaskNumber != nil, taskNumber != nil else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            if (self.displayedTaskNumber < self.taskNumber) {
                self.animateAdvanceSkinnerBox()
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isVisible = false
    }
    
    // MARK: - Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        friendsCollectionView.frame = CGRect(
            x: 10,
            y: 10,
            width: view.width - 20,
            height: 86
        )
        
        challengesLabel.sizeToFit()
        challengesLabel.frame = CGRect(
            x: 10,
            y: friendsCollectionView.bottom + 16,
            width: challengesLabel.width,
            height: challengesLabel.height
        )
        
        challengesCollectionView.frame = CGRect(
            x: 10,
            y: challengesLabel.bottom + 10,
            width: view.width - 20,
            height: 299
        )
        
        welcomeGradientLabel.sizeToFit()
        welcomeGradientLabel.frame = CGRect(
            x: (view.width - welcomeGradientLabel.width)/2,
            y: friendsCollectionView.bottom + 50,
            width: welcomeGradientLabel.width,
            height: welcomeGradientLabel.height
        )
        
        welcomeTextLabel.setFrameWithAutomaticHeight(
            x: 43.1,
            y: welcomeGradientLabel.bottom + 33.56,
            width: view.width - 86.2
        )
        
        skinnerBox.frame = CGRect(
            x: 0,
            y: welcomeTextLabel.bottom + 29.97,
            width: view.width,
            height: 152
        )
        
        skinnerBoxCompletionCircle.frame = CGRect(
            x: (view.width - 50)/2,
            y: skinnerBox.bottom + 63.6,
            width: 50,
            height: 50
        )
        
        let buttonSize = CGSize(width: 245, height: 59)
        
        noChallengesLabel.sizeToFit()
        noChallengesLabel.frame = CGRect(
            x: (view.width - noChallengesLabel.width)/2,
            y: challengesLabel.bottom + 20.02,
            width: noChallengesLabel.width,
            height: noChallengesLabel.height
        )
        
        createChallengeButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: view.height - 53 - buttonSize.height,
            width: buttonSize.width,
            height: buttonSize.height
        )
    }
    
    private func promptChallengesReceived(numChallenges: Int) {
        let prompt = Prompt()
        prompt.setTitle(text: "New challenges", isGradient: true)
        
        prompt.addTextWithBoldInRange(
            text: "Hey, you've been challenged \(numChallenges) time\(numChallenges != 1 ? "s" : ""), it's time to reply!",
            range: NSRange(location: 28, length: String(describing: numChallenges).count + 6)
        )
        
        prompt.addCompletionButton(buttonText: "Let's go!", style: .embedded, font: UIFont(name: "Raleway-Heavy", size: 20), closeOnTap: true)
        
        prompt.executesCompletionOnTapOutside = true
        prompt.onCompletion = { _ in
            self.challengesDataSource.reload()
            self.challengesCollectionView.reloadData()
            
            if ChallengeDataManager.shared.activeChallenges.count > 0 {
                self.configureForNotSkinnerBox()
            }
        }
        
        NavigationControlManager.displayPrompt(prompt)
    }
    
    private func animateAdvanceSkinnerBox() {
        skinnerBoxCompletionCircle.animateSetProgress(CGFloat(SkinnerBoxManager.shared.taskNumber) / CGFloat(SkinnerBoxManager.shared.numTasks))
        skinnerBoxCompletionCircle.setLabel("\(SkinnerBoxManager.shared.taskNumber)/\(SkinnerBoxManager.shared.numTasks)")
        if SkinnerBoxManager.shared.taskNumber == SkinnerBoxManager.shared.numTasks {
            skinnerBoxCompletionCircle.setColor(.XYGreen)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if SkinnerBoxManager.shared.taskNumber == SkinnerBoxManager.shared.numTasks {
                self.animateHideSkinnerBox()
            } else {
                self.skinnerBox.scrollToItem(at: IndexPath(row: self.taskNumber, section: 0), at: .left, animated: true)
            }
        }
        
        displayedTaskNumber = taskNumber
    }
    
    private func animateHideSkinnerBox() {
        guard taskNumber == SkinnerBoxManager.shared.numTasks else {
            return
        }
        
        // Hide Skinner box, configure for normal
        UIView.animate(withDuration: 0.3, delay: 0.5) {
            self.skinnerBoxCompletionCircle.alpha = 0.0
        } completion: { done in
            if done {
                UIView.animate(withDuration: 0.6, delay: 0.4) {
                    self.skinnerBox.alpha = 0.0
                    self.welcomeTextLabel.alpha = 0.0
                    self.welcomeGradientLabel.alpha = 0.0
                } completion: { done in
                    if done {
                        self.createChallengeButton.alpha = 0.0
                        self.createChallengeButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        self.challengesLabel.alpha = 1.0
                        self.noChallengesLabel.alpha = 1.0
                        
                        UIView.animate(withDuration: 0.6, delay: 0.4) {
                            self.createChallengeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self.createChallengeButton.alpha = 1.0
                            self.challengesLabel.alpha = 1.0
                            self.noChallengesLabel.alpha = 1.0
                        }
                        
                        self.configureForNotSkinnerBox()
                        self.friendsDataSource.reload()
                        self.friendsCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    private func configureForSkinnerBox() {
        challengesLabel.isHidden = true
        noChallengesLabel.isHidden = true
        createChallengeButton.isHidden = true
    }
    
    private func configureForNotSkinnerBox() {
        challengesLabel.isHidden = false
        noChallengesLabel.isHidden = challengesDataSource.challengesData.count != 0
        createChallengeButton.isHidden = false
        
        skinnerBox.isHidden = true
        skinnerBoxCompletionCircle.isHidden = true
        welcomeTextLabel.isHidden = true
        welcomeGradientLabel.isHidden = true
    }
    
    private func initializeChallenges() {
        NotificationCenter.default.addObserver(self, selector: #selector(onCoreDataPropertyUpdate), name: .NSManagedObjectContextObjectsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveChallenge), name: .didFinishDownloadingReceivedChallenges, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishSendingChallenge), name: .didFinishSendingChallenge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadActiveChallenges), name: .didLoadActiveChallenges, object: nil)
        
//        ChallengeDataManager.shared.fetchChallengeCards()
        
        ChallengeDataManager.shared.loadChallengesFromStorage()
        ChallengeDataManager.shared.setupChallengesListener()
    }
    
    private func initialiseSetup() {
        
        // Some coredata loading
        ProfileDataManager.shared.load() {
            self.initialiseFriends() {
                self.initializeChallenges()
            }
        }
    }
    
    private func initialiseFriends(completion: @escaping(() -> Void)) {
        NotificationCenter.default.addObserver(self, selector: #selector(onFriendsUpdated), name: .friendUpdateNotification, object: nil)
        
        FriendsDataManager.shared.loadDataFromStorage()
        FriendsDataManager.shared.loadAllUsersFromFirebase() {
            self.friendsDataSource.reload()
            self.friendsCollectionView.reloadData()
            
            if FriendsDataManager.shared.friends.count > 0 {
                SkinnerBoxManager.shared.taskNumber = 2
                SkinnerBoxManager.shared.save()
                self.configureForNotSkinnerBox()
            }
            
            completion()
        }
        FriendsDataManager.shared.setupFriendshipStatusListener()
    }
    
    func showNotificationsPrompt() {
        let prompt = Prompt()
        prompt.setTitle(text: "Enable Notifications")
        prompt.addText(text: "Get notified of friend requests and challenges.", font: UIFont(name: "Raleway-Bold", size: 19)!)
        prompt.addText(text: "You can change which notifications you see in the app settings.", font: UIFont(name: "Raleway-Regular", size: 12)!)
        prompt.addCompletionButton(
            buttonText: "Allow Notifications",
            textColor: .XYWhite,
            style: .action(style: .roundButtonGradient(gradient: Global.xyGradient)),
            font: UIFont(name: "Raleway-Heavy", size: 17),
            closeOnTap: true,
            onTap: {
                PushNotificationManager.shared.registerForPushNotifications()
                
                PushNotificationManager.shared.setHasPrompted(true)
            })
        prompt.addCompletionButton(
            buttonText: "Dismiss",
            textColor: UIColor.XYTint.withAlphaComponent(0.7),
            style: .embedded,
            font: UIFont(name: "Raleway-Regular", size: 13),
            closeOnTap: true,
            onTap: {
                PushNotificationManager.shared.setHasPrompted(true)
            })
        
        NavigationControlManager.displayPrompt(prompt)
    }
    
    @objc private func tappedNotifications() {
        let vc = NotificationsViewController()
        
        HapticsManager.shared.vibrateImpact(for: .light)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tappedSearch() {
        let vc = FindFriendsViewController()
        
        HapticsManager.shared.vibrateImpact(for: .light)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tappedCreateChallenge() {
        let vc = CreateChallengeViewController()
        
        HapticsManager.shared.vibrateImpact(for: .light)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func onFriendsUpdated() {
        friendsDataSource.reload()
        friendsCollectionView.reloadData()
        
        if friendsCollectionView.numberOfItems(inSection: 0) > 1 {
            SkinnerBoxManager.shared.completedTask(number: 1)
        }
    }
    
    @objc private func didLoadActiveChallenges() {
        self.challengesDataSource.reload()
        self.challengesCollectionView.reloadData()
        
        if ChallengeDataManager.shared.activeChallenges.count > 0 {
            self.configureForNotSkinnerBox()
        }
    }
    
    @objc private func didFinishSendingChallenge() {
        self.challengesDataSource.reload()
        self.challengesCollectionView.reloadData()
        
        if ChallengeDataManager.shared.activeChallenges.count > 0 {
            self.configureForNotSkinnerBox()
        }
    }
    
    @objc private func didReceiveChallenge() {
        let currentNumChallenges = challengesCollectionView.numberOfItems(inSection: 0)
        let newNumChallenges = ChallengeDataManager.shared.activeChallenges.count
        
        self.challengesDataSource.reload()
        self.challengesCollectionView.reloadData()
        
        self.promptChallengesReceived(numChallenges: newNumChallenges - currentNumChallenges)
    }
    
    @objc private func onCoreDataPropertyUpdate() {
        
    }
}

extension HomeViewController : SkinnerBoxManagerDelegate {
    
    func taskPressed(taskNumber: Int) {
        if taskNumber == 0 {
            // Open profile, open choose image
            let vc = EditProfileViewController()
            NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                vc.tappedProfileImage()
                
            }
        } else if taskNumber == 1 {
            // Open find friends screen
            let vc = FindFriendsViewController()
            
            NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onTaskComplete(taskNumber: Int) {
        self.taskNumber = taskNumber
        skinnerBox.reloadData()
        
        if isVisible {
            animateAdvanceSkinnerBox()
        }
    }
}
