//
//  HomeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class HomeViewController: UIViewController {
        
    private let friendsLabel = Label("Friends", style: .title)
    private let friendsCollectionView = FriendsCollectionView()
    
    private let challengesLabel = Label("Your Challenges", style: .title)
    private let challengesCollectionView = ChallengeCardsCollectionView()
    
    private let challengesDataSource = ChallengesDataSource()
    private let friendsDataSource = FriendsDataSource()
    
    private let welcomeGradientLabel = GradientLabel(text: "Welcome To XY!", fontSize: 40, gradientColours: Global.xyGradient)
    private let welcomeTextLabel = Label("Here you'll find your challenges, but you need to add a friend to start.", style: .body, fontSize: 20)
    private let addFriendButton = Button(title: "Find Friends", style: .roundButtonBorder(gradient: Global.xyGradient), font: UIFont(name: "Raleway-Heavy", size: 26))
    
    private let noChallengesLabel = Label("You have no challenges.", style: .body, fontSize: 18)
    private let createChallengeButton = Button(title: "Create new", style: .roundButtonBorder(gradient: Global.xyGradient), font: UIFont(name: "Raleway-Heavy", size: 26))
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(friendsLabel)
        view.addSubview(friendsCollectionView)
        view.addSubview(challengesLabel)
        view.addSubview(challengesCollectionView)
        
        view.addSubview(createChallengeButton)
        view.addSubview(welcomeGradientLabel)
        view.addSubview(welcomeTextLabel)
        view.addSubview(addFriendButton)
        view.addSubview(noChallengesLabel)
        
        welcomeTextLabel.numberOfLines = 0
        welcomeTextLabel.textAlignment = .center
        
        addFriendButton.addTarget(self, action: #selector(tappedSearch), for: .touchUpInside)
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
        
        // Fetch Challenges from storage
        ChallengeDataManager.shared.loadChallengesFromStorage()
        FriendsDataManager.shared.loadDataFromStorage()
        
        if FriendsDataManager.shared.friends.count == 0 {
            configureEmptyNoFriends()
        } else {
            friendsDataSource.reload()
            friendsCollectionView.reloadData()
            
            if ChallengeDataManager.shared.activeChallenges.count == 0 {
                configureEmptyNoChallenges()
            } else {
                challengesDataSource.reload()
                challengesCollectionView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadNewActiveChallenges), name: .didLoadActiveChallenges, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.configureBackgroundStyle(.visible)
        configureBackButton(.backButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch HomeStateManager.state {
        case .noFriends:
            configureEmptyNoFriends()
        case .noChallengesFirst, .noChallengesNormal:
            configureEmptyNoChallenges()
        case .normal:
            configureNormal()
        default: break
        }
        
        ChallengeDataManager.shared.loadNewActiveChallenge()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        friendsLabel.sizeToFit()
        friendsLabel.frame = CGRect(
            x: 10,
            y: 10,
            width: friendsLabel.width,
            height: friendsLabel.height
        )
        
        friendsCollectionView.frame = CGRect(
            x: 10,
            y: friendsLabel.bottom + 10,
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
            height: 200
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
        
        let buttonSize = CGSize(width: 245, height: 59)
        
        addFriendButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: view.height * 0.64,
            width: buttonSize.width,
            height: buttonSize.height
        )
        
        noChallengesLabel.sizeToFit()
        noChallengesLabel.frame = CGRect(
            x: (view.width - noChallengesLabel.width)/2,
            y: challengesLabel.bottom + 20.02,
            width: noChallengesLabel.width,
            height: noChallengesLabel.height
        )
        
        createChallengeButton.frame = CGRect(
            x: (view.width - buttonSize.width)/2,
            y: HomeStateManager.state == .normal ?
                view.height - 53 - buttonSize.height :
                noChallengesLabel.bottom + 22.02,
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
                self.configureNormal()
                
            }
        }
        
        NavigationControlManager.displayPrompt(prompt)
    }
    
    private func configureNormal() {
        HomeStateManager.state = .normal
        
        challengesLabel.isHidden = false
        createChallengeButton.isHidden = false
        
        noChallengesLabel.isHidden = true
        welcomeGradientLabel.isHidden = true
        welcomeTextLabel.isHidden = true
        addFriendButton.isHidden = true
        
        view.setNeedsLayout()
    }
    
    private func configureEmptyNoFriends() {
        HomeStateManager.state = .noFriends
        
        noChallengesLabel.isHidden = false
        welcomeGradientLabel.isHidden = false
        welcomeTextLabel.isHidden = false
        addFriendButton.isHidden = false
        
        challengesLabel.isHidden = true
        noChallengesLabel.isHidden = true
        createChallengeButton.isHidden = true
        
        view.setNeedsLayout()
    }
    
    private func configureEmptyNoChallenges() {
        HomeStateManager.state = .noChallengesFirst
        
        noChallengesLabel.isHidden = false
        createChallengeButton.isHidden = false
        challengesLabel.isHidden = false
        
        welcomeGradientLabel.isHidden = true
        welcomeTextLabel.isHidden = true
        addFriendButton.isHidden = true
        
        view.setNeedsLayout()
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
    
    @objc private func didLoadNewActiveChallenges() {
        let currentNumChallenges = challengesCollectionView.numberOfItems(inSection: 0)
        
        let newNumChallenges = ChallengeDataManager.shared.activeChallenges.count
        
        if newNumChallenges > currentNumChallenges {
            self.promptChallengesReceived(numChallenges: newNumChallenges - currentNumChallenges)
        }
    }
    
    func fetchOwnProfile() {
        
    }
    
    func fetchFriendsProfiles() {
        
    }
    
    func fetchChallenges() {
        
    }
}
